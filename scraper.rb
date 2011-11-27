#require 'rubygems'
require 'net/http'
require 'open-uri'
require 'json'
require 'mp3info'
require 'fileutils'

# Some constants
$debug = false
$time = Time.new

p "Let's get musical."

# Create new connection object and grab the AUTH cookie. This is how Hypem validates the keys it generates.
conn = Net::HTTP.new('hypem.com', 80)
response = conn.get('/')
cookie = response.response['set-cookie']

# Headers need to be in a hash.
headers = {	'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; rv:1.9) Gecko/20100101 Firefox/4.0', 'Cookie' => cookie }

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
	feed = "http://hypem.com/playlist/popular/3day/json/1/data.js"
	request = Net::HTTP.get_response(URI.parse(feed))
	response = request.body
	json_parse = JSON.parse(response, {'symbolize_names' => true})
	return json_parse
end

# We iterate through the objects returned by getids, and put the responses into an id array
ids = Array.new
getids.each_with_index do |item, index|
	# The first part of the object is a version identifier, so we'll skip it.
	if index > 0
		ids << item[1]["mediaid"]
	end
end

dir_name = $time.strftime('%Y%m%e')
already_ran = File.directory? dir_name

# This is where the magic happens
unless $debug || already_ran == true
	new_dir = FileUtils.mkdir dir_name
	for i in (0..9) 
		url = "/serve/source/" + ids[i] + "/" + keys[i]
		request = conn.get(url, headers)
		response = request.body
		json_obj = JSON.parse(response, {'symbolize_names' => true})
		mp3_url = json_obj["url"]

	  	# Save File
		filename = i.to_s + ".mp3"
		writeOut = open(dir_name + '/' + filename, "wb")
		  	writeOut.write(open(mp3_url).read)
		writeOut.close

		# Rewrite file name
	  	Mp3Info.open(dir_name + '/' + filename) do |mp3|
	    	title = mp3.tag.title 
	    	artist = mp3.tag.artist
	    	p "Downloading: " + title + " - " + artist + "..."
	    	new_filename = '0' + (i + 1).to_s + ' ' + artist + ' - ' + title + '.mp3'
	    	File.rename(dir_name + '/' + filename, dir_name + '/' + new_filename ) 
	    	p "Done."
		end
	end
else
	p "Already ran today!"
end