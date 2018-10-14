$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

if ENV['APP_ENV'].nil? || ENV['APP_ENV'] == 'development'
  require 'dotenv/load'
  Dotenv.load('.env.development')
end

require 'sinatra/base'
require 'table'
require 'view'
require 'entry_updater'

class ViewerApp < Sinatra::Application
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
end

class AdminApp < Sinatra::Application
  configure :production do
    set :force_ssl, true
  end

  use Rack::Auth::Basic do |username, password|
    username == ENV.fetch('ADMIN_USERNAME') && password == ENV.fetch('ADMIN_PASSWORD')
  end

  get '/admin' do
    @feeds = Table::SourceFeed.map do |sf|
      View::SourceFeed.new(sf.source_feed_id, sf.feed_url, sf.icon_url)
    end

    haml :admin
  end

  post '/admin/source_feeds' do
    file_ext  = File.extname(params[:source_feed_icon][:filename])
    icon_file = params[:source_feed_icon][:tempfile]
    feed_url  = params[:source_feed_url]

    Sequel::Model.db.transaction do
      icon_key = Table::SourceFeedIcon.insert_icon(icon_file, file_ext)
      icon_url = "/icons/#{icon_key}"
      Table::SourceFeed.insert(feed_url: feed_url, icon_url: icon_url)
    end

    Thread.new do
      sf = Table::SourceFeed.find(feed_url: feed_url)
      EntryUpdater.new(sf).run
    end

    redirect '/admin'
  end

  delete '/admin/source_feed/:source_feed_id' do
    source_feed_id = params[:source_feed_id].to_i
    source_feed = Table::SourceFeed.find(source_feed_id: source_feed_id)
    source_feed.destroy

    redirect '/admin'
  end
end

class App < Sinatra::Application
  use ViewerApp
  use AdminApp
end