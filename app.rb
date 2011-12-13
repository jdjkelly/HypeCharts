require 'rubygems'
require 'sinatra'
require 'json'
require 'net/http'

# Grabs the json feeds
class Popularblogs
      def getpopular
            feed = "http://hypem.com/playlist/popular/3day/json/1/data.js"
            request = Net::HTTP.get_response(URI.parse(feed))
            response = request.body
            json_parse = JSON.parse(response, {'symbolize_names' => true})
      end
end

get "/" do 

      # form the new request
      request  = Popularblogs.new.getpopular
      itemindex = request.length - 1

      # grab the parts from the json feed and stick them in a hash
      sitenames = Hash.new
      sitecounts = Hash.new

      # loop through the request, and make a new hash of the sitenames and sitevalues
      counter = 0
      (1..itemindex).each do
            sitename = request[counter.to_s]["sitename"]
            if sitenames.has_key?(sitename)
                  sitecount = sitenames[sitename]
                  sitecounts[sitename] = sitecount + counter + 1
                  sitenames.merge!(sitecounts)
            else
                  sitenames[sitename] = counter + 1
            counter += 1
      end

      # sort sitenames hash by value
      # @sorted = sitenames.sort_by {|k,v| v}




      erb :matcher
end