require './app/apilog.rb'
require 'apilog'

require 'dotenv'
require 'pocket'
require 'sinatra'
require 'slim'
require 'nobrainer'
require 'omniauth-fitbit'
require 'fitgem'

require 'pp'


Dotenv.load

use Rack::Session::Cookie, :secret => 'BSXeXTMJKuHUNvq2dLG6'
use OmniAuth::Builder do
    provider :fitbit, 'a973ef5421794ee39a48965e9925aaa4', '75441ab7391741708b3c385bfad14ef9'
end

Pocket.configure do |config| 
  config.consumer_key = ENV['pocket_consumer_key']
end

NoBrainer.configure do |config|
  config.rethinkdb_url = 'rethinkdb://localhost/apilog_dev'
end

run Sinatra::Application

# vim: set filetype=ruby
