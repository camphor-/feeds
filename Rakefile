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
    
  end
end