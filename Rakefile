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

Entry = Struct.new(:entry_url, :icon_filename, :title, :abstract, :published_at)

desc "Crawl registered source feed"
task :crawl do
  require 'crawler'
  require 'concurrent'

  entries = Queue.new

  pool = Concurrent::FixedThreadPool.new(10, auto_terminate: false)
  feeds = TomlRB.load_file(FEEDS_TOML, symbolize_keys: true)
  feeds.each do |username, feed|
    pool.post do
      Crawler.new(feed[:feed_url]).crawl.each do |crawled_entry|
        entry = Entry.new(
          crawled_entry.entry_url,
          feed[:icon_filename],
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
  entries = Array.new(entries.size) { entries.pop }

  # output
  FileUtils.rm_r(OUTPUT_DIR)
  Dir.mkdir(OUTPUT_DIR)

  # HTML
  entries = entries.sort_by(&:published_at).reverse.first(ENTRY_COUNT)
  entries_view_obj = entries.map do |e|
    View::Entry.new(
      e.entry_url,
      e.title,
      e.abstract,
      "/icons/#{e.icon_filename}",
      e.published_at
    )
  end

  result = Haml::Engine.new(File.read(TEMPLATE_PATH)).render(Object.new, entries: entries_view_obj)
  output_path = File.join(OUTPUT_DIR, 'index.html')
  File.write(output_path, result)

  # icons
  icon_dir = File.join(OUTPUT_DIR, 'icons')
  Dir.mkdir(icon_dir)
  source_paths = entries.map(&:icon_filename).uniq!
                     .map { |filename| File.join(ICON_DIR, filename) }
  FileUtils.cp(source_paths, icon_dir)
end
