require 'rss'
require 'faraday'
require 'faraday_middleware'
require 'concurrent'
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
          item.enclosure.url,
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

FEEDS_TOML = File.join(File.dirname(__FILE__), 'feeds.toml').freeze

entries = Queue.new
pool = Concurrent::FixedThreadPool.new(10, auto_terminate: false)
feeds = TomlRB.load_file(FEEDS_TOML, symbolize_keys: true)
feeds.each do |username, feed|
  pool.post do
    Crawler.new(feed[:feed_url]).crawl.each do |entry|
      entries.push(entry)
    end
  end
end
pool.shutdown
pool.wait_for_termination

entries = Array.new(entries.size) { entries.pop.to_h }
puts({entries: entries}.to_json)