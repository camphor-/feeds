require 'rss'
require 'faraday'
require 'faraday_middleware'

class Crawler
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
      feed.items.map do |item|
        Entry.new(
          item.link,
          item.title,
          item.description,
          item.date
        )
      end
    when RSS::Atom::Feed
      feed.items.map do |item|
        Entry.new(
          item.link.href,
          item.title.content,
          item.summary.content,
          item.published.content
        )
      end
    else
      puts "Unsupported feed type: #{feed.class} from #{@feed_url}"
    end
  end
end