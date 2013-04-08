# wtfdylan.rb
require 'sinatra'
require 'redis'

redis = Redis.new
redis.set("location", "AFRICA BITCHES")

get '/' do
    haml :index
end
