require 'sequel'
require 'dotenv/load'

Sequel::Model.db = Sequel.connect(ENV.fetch("DATABASE_URL"))

module Table
  class SourceFeed < Sequel::Model(:source_feeds)
    one_to_many :entries
  end

  class Entry < Sequel::Model(:entries)
    many_to_one :source_feed
  end

  class SourceFeedIcon < Sequel::Model(:source_feed_icons)
  end
end