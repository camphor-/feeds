require 'table'
require 'rss'
require 'faraday'
require 'faraday_middleware'

module Updater
  module SourceFeed
    def update(source_feed)
      crawled_source_feed = Crawler.new(source_feed.feed_url).crawl

      source_feed.update(title: crawled_source_feed.title, blog_url: crawled_source_feed.blog_url)
      Table::Entry.dataset.insert_conflict.multi_insert(
        crawled_source_feed.entries.map do |entry|
          {
            source_feed_id: source_feed.source_feed_id,
            entry_url: entry.entry_url, 
            title: entry.title,
            abstract: entry.abstract,
            published_at: entry.published_at
          }
        end
      )
    end
    module_function :update

    class Crawler
      SourceFeed = Struct.new(:blog_url, :title, :entries)
      Entry = Struct.new(:entry_url, :title, :abstract, :published_at)

      def initialize(feed_url)
        @feed_url = feed_url
      end

      def crawl
        conn = Faraday.new(@feed_url) do |b|
          b.use FaradayMiddleware::FollowRedirects
          b.adapter :net_http do |http|
            http.open_timeout = 2
          end
        end
        response = conn.get

        puts "status:#{response.status}\turl:#{@feed_url}"
        if response.status != 200
          return
        end

        feed = RSS::Parser.parse(response.body)

        case feed
        when RSS::Rss
          blog_url = feed.channel.link
          title = feed.channel.title
          entries = feed.items.map do |item|
            Entry.new(
              item.link,
              item.title,
              item.description,
              item.date
            )
          end
          SourceFeed.new(blog_url, title, entries)
        when RSS::Atom::Feed
          blog_url = feed.link.href
          title = feed.title.content
          entries = feed.items.map do |item|
            Entry.new(
              item.link.href,
              item.title.content,
              item.summary.content,
              item.published.content
            )
          end
          SourceFeed.new(blog_url, title, entries)
        else
          puts "Unsupported feed type: #{feed.class} from #{@feed_url}"
        end
      end
    end
  end
end
