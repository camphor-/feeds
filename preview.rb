require 'webrick'

WEBrick::HTTPServer.new(
  DocumentRoot: './dist',
  Port: 9292
).start