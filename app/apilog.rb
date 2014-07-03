require 'sinatra'
require 'date'
require 'chronic'
require 'statsample'
require 'google_visualr'

CALLBACK_URL = "http://localhost:4567/oauth/callback"

get '/fitbit' do
  if session[:fitbit_token] and session[:fitbit_secret]
    fitbit = Fitgem::Client.new(
      :consumer_key    => ENV['fitbit_consumer_key'],
      :consumer_secret => ENV['fitbit_consumer_secret'],
      :token           => session[:fitbit_token],
      :secret          => session[:fitbit_secret] )
    series = fitbit.data_by_time_range(
      '/activities/log/steps', 
      { :base_date => Chronic.parse('today'),
        :period    => '3m' } )
    data_table = GoogleVisualr::DataTable.new
    data_table.new_columns(
      [ { :type => 'datetime', :label => 'Date'},
        { :type => 'number',   :label => 'Steps'},
        { :type => 'number',   :label => '7-day median'},
        { :type => 'number',   :label => '3-day mean'} ] )
    steps = series['activities-log-steps']
    rolling_median = rolling_func(steps, 7) {|a| a.to_scale.median }
    rolling_mean = rolling_func(steps, 3) {|a| a.to_scale.mean }
    data = steps.map{|day| 
      [ Chronic.parse(day['dateTime']), 
        day['value'].to_i, 
        rolling_median.shift,
        rolling_mean.shift
      ] }
    data_table.add_rows(data)
    @chart = GoogleVisualr::Interactive::LineChart.new(data_table)
    slim :fitbit
  else
    redirect('/auth/fitbit')
  end
end

get '/auth/:name/callback' do |name|
  token_name, secret_name  = "#{name}_token", "#{name}_secret"
  session[token_name.to_s] = 
    request.env['omniauth.auth']['credentials']['token']
  session[secret_name.to_s] = 
    request.env['omniauth.auth']['credentials']['secret']
  redirect('/fitbit')
end


get '/reset' do
  puts "GET /reset"
  session.clear
end

get "/" do
  puts "GET /"
  puts "session: #{session}"
  
  last_week = Chronic.parse('last week')
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
  @days = params[:days] ? params[:days].to_i : 10
  @last_day = params[:date] ? Time.parse(params[:date]) : Time.now
  @stories = PocketStory.take(@days, :date => @last_day)
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

get "/retrieve/pocket/since/:date" do |date|
  get_stories_since :date => date
  redirect "me"
end

helpers do
  def rolling_func(series, days)
    acc = []
    series.map{|day|
      a = acc.push(day['value'].to_i)
      m = a.count >= days ? yield(a.sort) : nil
      acc.shift if acc.count >= days
      m }
  end
  def pocket_time(date)
    Time.parse(date).strftime('%s')
  end

  def get_stories_since(args)
    date = args[:date]
    client = Pocket.client(:access_token => session[:access_token])
    info = client.retrieve :detailType => :simple, :since => pocket_time(date)
    PocketStoryController :response => info
  end

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
