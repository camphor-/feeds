require 'rss'
require 'faraday'

class Crawl
  Entry = Struct.new(:entry_url, :title, :abstract, :published_at)

  def initialize(feed_url)
    @feed_url = feed_url
  end

  def crawl
    xml_txt = Faraday.get(@feed_url).body
    feed = RSS::Parser.parse(xml_txt)

    case feed
    when RSS::Rss
      feed.items.each do |item|
        yield Entry.new(
          item.link,
          item.title,
          item.description,
          item.date
        )
      end
    when RSS::Atom::Feed
      feed.items.each do |item|
        yield Entry.new(
          item.link.href,
          item.title.content,
          item.content.content,
          item.published.content
        )
      end
    else
      raise "Unsupported feed type: #{feed.class}"
    end
  end
end
