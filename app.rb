require 'rubygems'
require 'sinatra'
require 'json'
require 'net/http'

# Grabs the json feeds 
def getpopular(page)
      feed = "http://hypem.com/playlist/popular/3day/json/" + page.to_s + "/data.js"
      #feed = "http://localhost:4567/json.js"
      request = Net::HTTP.get_response(URI.parse(feed))
      response = request.body
      json_parse = JSON.parse(response, {'symbolize_names' => true})
      return json_parse
end


get '/' do 
      ids = Hash.new
            ids2 = Hash.new
            for i in (1..5)
                  getpopular(i).each_with_index do |item, index|
                        if index > 0
                              sitename = item[1]["sitename"]
                              if ids.has_key?(sitename)
                                    old_value = ids[sitename]
                                    ids2[sitename] = old_value + 1
                                    ids.merge!(ids2)
                              else      
                                    ids[sitename] = 1
                              end
                        end
                  end
            end
            @sorted = ids.sort_by {|k,v| v}.reverse
      erb :matcher
end

get '/genres' do 
      "Coming soon"
end

get '/artists' do 
      "Coming soon"
end

get '/tracks' do 
      "Coming soon"
end

get '/genres' do 
      "Coming soon"
end