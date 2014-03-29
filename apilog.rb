require "sinatra"
require "pp"
require "dotenv"
require "./lib/apilog.rb"
require 'slim'

Dotenv.load
use Rack::Session::Cookie, :secret => 'BSXeXTMJKuHUNvq2dLG6'
CALLBACK_URL = "http://localhost:4567/oauth/callback"
Pocket.configure do |config| 
  config.consumer_key = ENV['pocket_consumer_key']
end
DataMapper.finalize

get '/reset' do
  puts "GET /reset"
  session.clear
end

get "/" do
  puts "GET /"
  puts "session: #{session}"
  
  if session[:access_token]
    redirect "/retrieve"
  else
    '<a href="/oauth/connect">Connect with Pocket</a>'
  end
end

get "/oauth/connect" do
  puts "OAUTH CONNECT"
  session[:code] = Pocket.get_code(:redirect_uri => CALLBACK_URL)
  new_url = Pocket.authorize_url(:code => session[:code], :redirect_uri => CALLBACK_URL)
  puts "new_url: #{new_url}"
  puts "session: #{session}"
  redirect new_url
end

get "/oauth/callback" do
  puts "OAUTH CALLBACK"
  puts "request.url: #{request.url}"
  puts "request.body: #{request.body.read}"
  access_token = Pocket.get_access_token(session[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = access_token
  puts "session: #{session}"
  redirect "/"
end

get '/add' do
  client = Pocket.client(:access_token => session[:access_token])
  info = client.add :url => 'http://geknowm.com'
  "<pre>#{info}</pre>"
end

get "/retrieve" do
  client = Pocket.client(:access_token => session[:access_token])
  info = client.retrieve :detailType => :simple, :state => :all

  # html = "<h1>#{user.username}'s recent photos</h1>"
  # for media_item in client.user_recent_media
  #   html << "<img src='#{media_item.images.thumbnail.url}'>"
  # end
  # html
  # "<pre>#{info}</pre>"
  info["list"].each do |item_id,item_hash|
    PocketStory.new(:raw_id => item_id, :raw => item_hash)
  end
  "#{info.to_s}"
end

get "/retrieve/since/:epoch" do
  client = Pocket.client(:access_token => session[:access_token])
  info = client.retrieve :detailType => :simple, :since => params[:epoch]
  info["list"].each do |id, item|
    begin
    time_added = DateTime.strptime(item["time_added"], '%s')
    time_read = if item["time_read"] != '0'
                  DateTime.strptime(item["time_read"], '%s')
                else
                  nil
                end
    ps = PocketStory.create(
      :pocket_id      => id.to_i,
      :resolved_url   => item["resolved_url"],
      :resolved_title => item["resolved_title"],
      :time_added     => time_added,
      :time_read      => time_read
    )
    pp ps.inspect
    rescue => e
      pp "Error: #{e}"
    end
  end
  "#{info}"
end
