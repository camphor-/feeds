$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

require 'sinatra'
require 'table'
require 'view'

get '/' do
  @entries = Table::Entry.order(Sequel.desc(:published_at)).map do |e|
    View::Entry.new(e.entry_url, e.title, e.abstract, e.published_at)
  end

  haml :index
end