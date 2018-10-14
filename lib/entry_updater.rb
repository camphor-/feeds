require 'table'
require 'crawler'

class EntryUpdater
  def initialize(source_feed)
    @source_feed = source_feed
  end

  def run
    Crawler.new(@source_feed.feed_url).crawl do |entry|
      Table::Entry.dataset.insert_conflict.insert(
        source_feed_id: @source_feed.source_feed_id,
        entry_url: entry.entry_url, 
        title: entry.title,
        abstract: entry.abstract,
        published_at: entry.published_at
      )
    end
  end
end