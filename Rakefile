$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require 'sequel/core'
    require 'dotenv/load'
    require 'logger'
    Dotenv.load('.env.development')

    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect(ENV.fetch("DATABASE_URL"), logger: Logger.new($stderr)) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end
end

namespace :source do
  task :add do |args|
    require 'table'

    _, feed_url = ARGV

    Table::SourceFeed.insert(feed_url: feed_url)

    puts "Added source: #{feed_url}"

    exit
  end
end