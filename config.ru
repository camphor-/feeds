require './server'

map('/') { run ViewerApp }
map('/admin') { run AdminApp }
