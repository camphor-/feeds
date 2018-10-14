$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

if ENV['APP_ENV'].nil? || ENV['APP_ENV'] == 'development'
  require 'dotenv/load'
  Dotenv.load('.env.development')
end

require 'sinatra'
require 'table'
require 'view'

get '/' do
  @entries = Table::Entry.order(Sequel.desc(:published_at)).limit(50).map do |e|
    View::Entry.new(e.entry_url, e.title, e.abstract, e.source_feed.icon_url, e.published_at)
  end

  haml :index
end

ICON_CACHE_DIR = ENV['ICON_CACHE_DIR'] || '/tmp'
get '/icons/:icon_key' do
  cached_path = ICON_CACHE_DIR + '/' + params[:icon_key]

  if !File.exists?(cached_path)
    feed_icon = Table::SourceFeedIcon.where(key: params[:icon_key]).first
    raise Sinatra::NotFound if feed_icon.nil?

    File.write(cached_path, feed_icon.content)
  end

  send_file cached_path
end