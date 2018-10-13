require 'nokogiri'

module View
  class Entry
    attr_reader :entry_url, :title

    def initialize(entry_url, title, abstract_html)
      @entry_url = entry_url
      @title = title
      @abstract_html = abstract_html
    end

    def abstract
      Nokogiri::HTML(@abstract_html).text
    end
  end
end