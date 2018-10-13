require 'nokogiri'

module View
  class Entry
    attr_reader :entry_url, :title, :published_at

    def initialize(entry_url, title, abstract_html, published_at)
      @entry_url = entry_url
      @title = title
      @abstract_html = abstract_html
      @published_at = published_at
    end

    def abstract
      Nokogiri::HTML(@abstract_html).text
    end
  end
end