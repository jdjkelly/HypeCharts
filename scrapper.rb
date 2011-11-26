require 'rubygems'
require 'net/http'
require 'json'

# Create new connection object
conn = Net::HTTP.new('hypem.com', 80)

# Get the response on initial request to grab the cookie!
response = conn.get('/popular')
cookie = response.response['set-cookie']
re = /AUTH=\S{70}/
auth = cookie.match re

# Headers need to be in a hash.
headers = {
	'Host' => 'hypem.com',
	'Connection' => 'keep-alive',
	'X-Requested-With' => 'XMLHttpRequest',
	'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2',
	'Accept' => 'application/json, text/javascript, */*; q=0.01',
	'Referer' => 'http://hypem.com/',
	'Accept-Encoding' => 'gzip,deflate,sdch',
	'Accept-Language' => 'en-US,en;q=0.8',
	'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
	'Cookie' => auth[0].to_s
	}

# Get the data from hypem
response = conn.get('/popular', headers)

# Convert resposne to string, use String#scan to scan text, iterating through the matches. Keys are uniquely generated when your browser actually visits hypem.
regex_input = response.body.to_s
keys = Array.new
regex_input.scan(/\w{32}/) { |match| 
  keys << match
}

# Now we have to get the song ids. In the future, maybe I should scrape them from the same source as the keys - when I get better at ruby regex's.
def getids 
	http = "http://hypem.com/playlist/popular/3day/json/1/data.js"
	req = Net::HTTP.get_response(URI.parse(http))
	response = req.body
	json_parse = JSON.parse(response, {'symbolize_names' => true})
	return json_parse
end

# We iterate through the objects returned by getids, and put the responses into an id array
ids = Array.new
getids.each_with_index do |item, index|
	# The first part of the object is a version identifier, so we'll skip it.
	if index > 1
		ids << item[1]["mediaid"]
	end
end

for i in (1..1)
	url = "/serve/source/" + ids[i] + "/" + keys[i] + "?_=" + Time.now.to_i.to_s
	response = conn.get(url, headers)
	header = response.header
	p header
end

