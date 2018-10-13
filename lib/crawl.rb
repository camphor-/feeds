require 'rss'
require 'faraday'

class Crawl
  Entry = Struct.new(:entry_url, :title, :abstract, :media_url)

  def initialize(feed_url)
    @feed_url = feed_url
  end

  def crawl
    xml_txt = Faraday.get(@feed_url).body
    feed = RSS::Parser.parse(xml_txt)

    case feed
    when RSS::Rss
      feed.items.each do |item|
        yield Entry.new(item.link, item.title, item.description, nil)
      end
    when RSS::Atom::Feed
      feed.items.each do |item|
        yield Entry.new(item.link.href, item.title.content, item.content.content, nil)
      end
    end
  end
end
