require 'webrick'

WEBrick::HTTPServer.new(
  DocumentRoot: ARGV[0],
  Port: 9292
).start
