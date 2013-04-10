# wtfdylan.rb
require 'sinatra'

configure do
  require 'redis'
  require 'twilio-ruby'

  # put your own credentials here
   account_sid = "ACaf8cca4999752edc5deb7edacbbc7350"
   auth_token = "904cafb05863471d96567cecfdbd4cf5"
   from = '+17139994373'
 
   # set up a client to talk to the Twilio REST API
   @client = Twilio::REST::Client.new account_sid, auth_token
   @account = @client.account

end

configure :testing, :development do
  REDIS = Redis.new
  REDIS.rpush 'location', 'AFRICA!'
end

configure :production do
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/' do
    haml :index
end

post '/' do

	# get that location into redis stat!
    begin
      message = "Got your message, #{params[:From]} in #{params[:FromCountry]}!\n"

      raise "Missing parameters (params contains {#{params.inspect})" if params[:Body].nil?
      # raise "AccountSid mismatch" if params[:AccountSid] != @account_sid
    
      REDIS.rpush 'location', params[:Body]
      REDIS.rpush 'actual_location', params[:FromCountry] if !params[:FromCountry].nil?
      # REDIS.bgsave ### rediscloud doesn't allow this

      rescue Exception => errormsg
      	message = message + "But had a error: #{errormsg}"

      else
      	message = message + "And it's live!"
    end


    twiml = Twilio::TwiML::Response.new do |r|
        r.Sms message
    end
    twiml.text 

end