require 'nokogiri'

module View
  class Entry
    attr_reader :entry_url, :title

    def initialize(entry_url, title, abstract_html, icon_url, published_at)
      @entry_url = entry_url
      @title = title
      @abstract_html = abstract_html
      @icon_url = icon_url
      @published_at = published_at
    end

    def abstract
      Nokogiri::HTML(@abstract_html).text
    end

    def icon_url
      @icon_url || ENV['DEFAULT_ENTRY_ICON_URL']
    end

    def published_at
      @published_at.strftime('%Y-%m-%d %H:%M')
    end
  end

  class SourceFeed
    attr_reader :feed_id, :title, :feed_url, :icon_url, :blog_url

    def initialize(feed_id, title, feed_url, icon_url, blog_url)
      @feed_id = feed_id
      @title = title
      @feed_url = feed_url
      @icon_url = icon_url
      @blog_url = blog_url
    end
  end
end
