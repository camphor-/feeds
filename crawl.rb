#!/bin/usr/env ruby
require 'rss'
require 'faraday'
require 'faraday_middleware'
require 'json'
require 'toml-rb'

class Crawler
  Entry = Struct.new(:entry_url, :title, :abstract, :icon_url, :published_at)

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

    STDERR.puts "status:#{response.status}\turl:#{@feed_url}"
    if response.status != 200
      return
    end

    feed = RSS::Parser.parse(response.body)

    case feed
    when RSS::Rss
      feed.items.map do |item|
        Entry.new(
          item.link,
          item.title,
          item.description,
          item.enclosure&.url,
          item.date
        )
      end
    when RSS::Atom::Feed
      feed.items.map do |item|
        Entry.new(
          item.link.href,
          item.title.content,
          item.summary.content,
          item.links.find { |link| link.rel == 'enclosure' }&.href,
          item.published.content
        )
      end
    else
      puts "Unsupported feed type: #{feed.class} from #{@feed_url}"
    end
  end
end

toml_string = $stdin.read
feeds = TomlRB.parse(toml_string, symbolize_keys: true)

entries = feeds.map {|username, feed| Crawler.new(feed[:feed_url]).crawl }.reject(&:nil?).flatten.map(&:to_h)
puts({entries: entries}.to_json)
