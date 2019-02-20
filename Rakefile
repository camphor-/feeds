$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

require 'dotenv/load'
require 'haml'
require 'view'
require 'fileutils'
Dotenv.load('.env.development')

OUTPUT_DIR = File.join(File.dirname(__FILE__), 'dist').freeze
TEMPLATE_PATH = File.join(File.dirname(__FILE__), 'templates', 'index.haml').freeze
ICON_DIR = File.join(File.dirname(__FILE__), 'icons').freeze
ENTRY_COUNT = 50.freeze

desc "Crawl registered source feed"
task :crawl do
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
