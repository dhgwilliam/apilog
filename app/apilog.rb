require 'sinatra'
require 'date'

CALLBACK_URL = "http://localhost:4567/oauth/callback"

get '/reset' do
  puts "GET /reset"
  session.clear
end

get "/" do
  puts "GET /"
  puts "session: #{session}"
  
  last_week = (Date.today - 7).strftime('%Y-%m-%d')
  if session[:access_token]
    redirect "/retrieve/pocket/since/#{last_week}"
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

get '/me' do
  days = params[:days] || 10
  @bucket_page = PocketStory.take(days.to_i)
  slim :me
end


get "/retrieve/pocket" do
  client = Pocket.client(:access_token => session[:access_token])
  info = client.retrieve :detailType => :simple, :state => :all
  PocketStoryController :response => info
  redirect "me"
end

get '/retrieve/twitter' do
  TWITTER_CLIENT.user('dhgwilliam')
end

get "/retrieve/pocket/since/:date" do
  epoch = Time.parse(params[:date]).strftime('%s')
  client = Pocket.client(:access_token => session[:access_token])
  info = client.retrieve :detailType => :simple, :since => epoch
  PocketStoryController :response => info
  redirect "me"
end

helpers do
  def PocketStoryController(args)
    if args[:response]["list"]
      list = args[:response]["list"]
    else
      list = args[:response]
    end

    list.each do |id, item|
      begin
        time_added = Time.strptime(item["time_added"], '%s')
        time_read = if item["time_read"] != '0'
            Time.strptime(item["time_read"], '%s')
          else
            nil
          end
        PocketStory.create({
          :pocket_id  => id.to_i,
          :url        => item["resolved_url"],
          :title      => item["resolved_title"],
          :time_added => time_added,
          :time_read  => time_read
        })
        pp "successfully stored #{id}"
      rescue Exception => e
        pp "Error: #{id} #{e}"
      end
    end
  end
end
