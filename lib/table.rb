require 'sequel'
require 'dotenv/load'

Dotenv.load('.env.development')

Sequel::Model.db = Sequel.connect(ENV.fetch("DATABASE_URL"))

module Table
  class SourceFeed < Sequel::Model(:source_feeds)
  end
end