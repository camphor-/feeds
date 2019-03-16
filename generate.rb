#!/bin/usr/env ruby
require 'nokogiri'
require 'fileutils'
require 'json'
require 'time'

module View
  class Entry < Struct.new(:entry_url, :title, :abstract_html, :icon_url, :published_at)
    def abstract
      Nokogiri::HTML(self.abstract_html).text
    end

    alias :old_published_at :published_at
    def published_at
      old_published_at.strftime('%Y-%m-%d %H:%M')
    end

    alias :old_to_h :to_h
    def to_h
      old_to_h.merge(abstract: self.abstract, published_at: self.published_at)
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

ENTRY_COUNT = 50.freeze

entries_json_string = STDIN.read
entries = JSON.parse(entries_json_string)['entries'].map do |e|
  View::Entry.new(
    e['entry_url'],
    e['title'],
    e['abstract'],
    e['icon_url'],
    Time.parse(e['published_at'])
  )
end.sort_by(&:published_at).reverse.first(ENTRY_COUNT)

puts JSON.dump(entries.map(&:to_h))
