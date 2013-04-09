# wtfdylan.rb
require 'sinatra'

configure do
  require 'redis'
end

configure :testing, :development do
  REDIS = Redis.new
  REDIS.set("location", "AFRICA BITCHES")
end

configure :production do
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/' do
    haml :index
end
