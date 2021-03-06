require 'rubygems'
require 'sinatra'
# Can't get reloader to work yet (windows thing...)
# require 'sinatra/reloader'
require 'json'
require 'net/http'
require 'data_mapper'
require 'dm-migrations'

DataMapper.setup( :default, "sqlite3://#{Dir.pwd}/dev2.db" )

class Dataset
      include DataMapper::Resource

      property :id,     Serial
      property :data,   Text
      property :date,   DateTime

end

DataMapper.auto_migrate!

def hypemsearch
      "Starting search..."
      url = "http://hypem.com/playlist/popular/3day/json/1/data.js"
      request = Net::HTTP.get_response(URI.parse(url))
      response = resp.body
      "Found Hype Machine feed..."

      json = JSON.parse(response)

      r = Dataset.new
      @r.data = data
      @r.date = Time.now
      @r.save
end

get '/params/:name' do
      "Hello #{params[:name]}!"
end

get '/update' do
      hypemsearch
      erb :update
end

get '/date/:date' do
      hypemsearch
      @data = Dataset.get(1)
      code = "<%= @data.date %>"
      erb code
end