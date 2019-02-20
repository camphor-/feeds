require 'nokogiri'
require 'dotenv/load'
require 'haml'
require 'fileutils'
require 'json'
require 'time'

Dotenv.load('.env.development')

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
      @icon_url
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

OUTPUT_DIR = File.join(File.dirname(__FILE__), ARGV[0]).freeze
TEMPLATE_PATH = File.join(File.dirname(__FILE__), 'templates', 'index.haml').freeze
ICON_DIR = File.join(File.dirname(__FILE__), 'icons').freeze
ENTRY_COUNT = 50.freeze

json_string = STDIN.read
entries = JSON.parse(json_string)['entries'].map do |e|
  View::Entry.new(
    e['entry_url'],
    e['title'],
    e['abstract'],
    e['icon_url'],
    Time.parse(e['published_at'])
  )
end.sort_by(&:published_at).reverse.first(ENTRY_COUNT)

FileUtils.rm_r(OUTPUT_DIR) if File.exist?(OUTPUT_DIR)
Dir.mkdir(OUTPUT_DIR)
result = Haml::Engine.new(File.read(TEMPLATE_PATH)).render(Object.new, entries: entries)
output_path = File.join(OUTPUT_DIR, 'index.html')
File.write(output_path, result)