$LOAD_PATH << File.dirname(File.expand_path(__FILE__)) + '/lib'

require 'dotenv/load'
Dotenv.load('.env.development')
