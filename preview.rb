#! /usr/bin/env ruby
require 'webrick'

WEBrick::HTTPServer.new(
  DocumentRoot: ARGV[0] || './dist',
  Port: 9292
).start
