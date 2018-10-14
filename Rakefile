$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

if ENV['APP_ENV'].nil? || ENV['APP_ENV'] == 'development'
  require 'dotenv/load'
  Dotenv.load('.env.development')
end

namespace :db do
  require 'sequel/core'
  require 'logger'
  Sequel.extension :migration
  DB = Sequel.connect(ENV.fetch("DATABASE_URL"))

  desc "Prints current schema version"
  task :version do
    version = if DB.tables.include?(:schema_info)
      DB[:schema_info].first[:version]
    end || 0

    puts "Schema Version: #{version}"
  end

  desc "Run migrations"
  task :migrate do
    Sequel::Migrator.run(DB, "db/migrations")
    Rake::Task["db:version"].execute
  end

  desc "Rollback to specified version"
  task :rollback, :target do |t, args|
    target = ARGV[1]

    raise 'Specify migration version!' unless target

    Sequel::Migrator.run(DB, "db/migrations", target: target.to_i)
    Rake::Task["db:version"].execute

    exit
  end
end

namespace :source do
  desc "Register source feed"
  task :add do |args|
    require 'table'

    _, feed_url, icon_url = ARGV

    Table::SourceFeed.insert(feed_url: feed_url, icon_url: icon_url)

    puts "Added source: #{feed_url}"

    exit
  end

  desc "Crawl registered source feed"
  task :crawl do
    require 'table'
    require 'crawl'
    require 'concurrent'

    pool = Concurrent::FixedThreadPool.new(5, auto_terminate: false)

    Table::SourceFeed.each do |sf|
      pool.post do
        Crawl.new(sf.feed_url).crawl do |entry|
          Table::Entry.dataset.insert_conflict.insert(
            source_feed_id: sf.source_feed_id,
            entry_url: entry.entry_url, 
            title: entry.title,
            abstract: entry.abstract,
            published_at: entry.published_at
          )
        end
      end
    end

    pool.shutdown
    pool.wait_for_termination
  end
end