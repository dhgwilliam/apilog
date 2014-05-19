require './app/apilog.rb'
require 'apilog'

require 'dotenv'
require 'pocket'
require 'sinatra'
require 'slim'
require 'nobrainer'

require 'pp'


Dotenv.load

use Rack::Session::Cookie, :secret => 'BSXeXTMJKuHUNvq2dLG6'

Pocket.configure do |config| 
  config.consumer_key = ENV['pocket_consumer_key']
end

NoBrainer.configure do |config|
  config.rethinkdb_url = 'rethinkdb://localhost/apilog_dev'
end

run Sinatra::Application
