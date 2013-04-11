# wtfdylan.rb
require 'sinatra'

configure do
  require 'redis'
  require 'twilio-ruby'

  # Set up Twilio
  account_sid = ENV["TWILIO_SID"]
  auth_token = ENV["TWILIO_AUTH"]
  from = ENV["TWILIO_FROM"]  

  # set up a client to talk to the Twilio REST API
  @client = Twilio::REST::Client.new account_sid, auth_token
  @account = @client.account
end

configure :testing, :development do
  REDIS = Redis.new
  REDIS.rpush 'location', 'AFRICA!'
end

configure :production do
  # Set up RedisCloud
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/' do
    haml :index
end

post '/' do

	# get that location into redis stat!
    begin
      message = "Got your message, #{params[:From]}"
      message += " in #{params[:FromCountry]}" if !params[:FromCountry].nil?
      message += "!\n"

      raise "Missing parameters (params contains {#{params.inspect})" if params[:Body].nil?
      # raise "AccountSid mismatch" if params[:AccountSid] != @account_sid
    
      REDIS.rpush 'location', params[:Body]
      REDIS.rpush 'actual_location', params[:FromCountry] if !params[:FromCountry].nil?
      REDIS.rpush 'params', "#{params.inspect}"

      rescue Exception => errormsg
      	message = message + "But had a error: #{errormsg}"

      else
      	message = message + "And it's live!"
    end


    twiml = Twilio::TwiML::Response.new do |r|
        r.Sms message
    end
    twiml.text


get '/privacy' do     #hilarious, I know
  "It's just me: one author, one user."
  return
end


end