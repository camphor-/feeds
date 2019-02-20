$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

require 'toml-rb'
require 'dotenv/load'
require 'haml'
require 'view'
require 'fileutils'
Dotenv.load('.env.development')

FEEDS_TOML = File.join(File.dirname(__FILE__), 'feeds.toml').freeze
OUTPUT_DIR = File.join(File.dirname(__FILE__), 'dist').freeze
TEMPLATE_PATH = File.join(File.dirname(__FILE__), 'templates', 'index.haml').freeze
ICON_DIR = File.join(File.dirname(__FILE__), 'icons').freeze
ENTRY_COUNT = 50.freeze

desc "Crawl registered source feed"
task :crawl do
  require 'crawler'
  require 'concurrent'
  require 'json'

  Entry = Struct.new(:entry_url, :icon_url, :title, :abstract, :published_at)
  entries = Queue.new

  pool = Concurrent::FixedThreadPool.new(10, auto_terminate: false)
  feeds = TomlRB.load_file(FEEDS_TOML, symbolize_keys: true)
  feeds.each do |username, feed|
    pool.post do
      Crawler.new(feed[:feed_url]).crawl.each do |crawled_entry|
        entry = Entry.new(
          crawled_entry.entry_url,
          crawled_entry.icon_url,
          crawled_entry.title,
          crawled_entry.abstract,
          crawled_entry.published_at
        )
        entries.push(entry)
      end
    end
  end

  pool.shutdown
  pool.wait_for_termination
  puts({entries: Array.new(entries.size) { entries.pop.to_h }}.to_json)
end

desc "generate html from entry json"
task :genhtml do
  require 'json'
  require 'time'

  entries = JSON.parse(STDIN.read)['entries'].map do |e|
    View::Entry.new(
      e['entry_url'],
      e['title'],
      e['abstract'],
      e['icon_url'],
      Time.parse(e['published_at'])
    )
  end.sort_by(&:published_at).reverse.first(ENTRY_COUNT)

  # output
  FileUtils.rm_r(OUTPUT_DIR)
  Dir.mkdir(OUTPUT_DIR)

  # HTML
  result = Haml::Engine.new(File.read(TEMPLATE_PATH)).render(Object.new, entries: entries)
  output_path = File.join(OUTPUT_DIR, 'index.html')
  File.write(output_path, result)
end
