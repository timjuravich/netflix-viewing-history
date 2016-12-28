#!/usr/bin/env ruby
require 'iconv'
require 'nokogiri'
require 'date'

# Config
PAGE_LOAD_WAIT  = 20
NETFLIX_META_OUTPUT  = File.dirname(__FILE__) + "/output/netflix-meta.txt"
NETFLIX_RAW_OUTPUT  = File.dirname(__FILE__) + "/output/netflix-raw.txt"

# Character encoding converter instance used to force all HTML output into UTF-8 format
ICONV           = Iconv.new('UTF-8//IGNORE', 'UTF-8')

def get_netflix_movie_info(html)
  page = Nokogiri::HTML(html)

  rating = page.xpath('//div[@class="jawBone"]//span[@class="maturity-rating"]').text.strip
  duration = page.xpath('//div[@class="jawBone"]//span[@class="duration"]').text.strip

  if duration.include?("Season") || duration.include?("Series")
    type = "series"
    length = 30 # probably not best to hardcode...
  else
    type = "movie"
    time = duration.split(" ")

    if time.size == 2
      # has hours and minutes
      length = (time[0].chomp('h').to_i * 60) + time[1].chomp('m').to_i
    else
      # just minutes
      length = time[1].chomp('m').to_i
    end
  end

  {:rating => rating, :length => length, :type => type}
end

# Obtain the HTML source for the given URL
def get_netflix_movie_html(url)
  applescript = <<-EOF
    tell application "Safari"
      activate
      set url of document 1 to "#{url}"
      delay #{PAGE_LOAD_WAIT}
      set htmlSource to do JavaScript "document.body.innerHTML" in document 1
      set the clipboard to htmlSource as text
    end tell
  EOF
  ICONV.iconv(`osascript -e '#{applescript}' && pbpaste` + ' ')[0..-2]
end

def get_raw_data()
  raw_data = []
  File.open(NETFLIX_RAW_OUTPUT, "r").each_with_index do |line, index|
    row = line.chomp("\n")
    data = row.split(/\;/)
    raw_data.push({ :raw => row, :title => data[1],:url => "https://www.netflix.com#{data[2]}" })
  end
  raw_data
end

raw_data = get_raw_data()
series_data = []
existing_series = []

raw_data.each_with_index do |row, index|
  potential_series_title = row[:title].split(":").first

  existing_series = series_data.find {|r| r[:series_title] == potential_series_title}

  if existing_series
    puts "it existed, use the data"
    # use its data and skip
    raw_data[index] = row.merge(existing_series[:data])
    puts raw_data[index]
  else
    # it doesnt exist, go get it
    puts "it didnt exist, get new data"
    scraped_data = get_netflix_movie_info(get_netflix_movie_html(row[:url]))

    # put the data into a series data array for future use
    series_data << {:series_title => raw_data[index][:title].split(":").first, :data => scraped_data}

    # inject the scraped data into the original raw data source
    raw_data[index] = row.merge(scraped_data)
    puts raw_data[index]
  end
  break if index > 20
end

# Rewrite the file including the new meta informatio
File.open(NETFLIX_META_OUTPUT, "a") do |file|
  # file.puts "Date;Title;URL;Rating;Length;Type"
  raw_data.each do |row|
   file.puts "#{row[:raw]};#{row[:rating]};#{row[:length]};#{row[:type]}"
  end
end

File.open(output_file, "w") do |out_file|
  File.foreach(input_file) do |line|
    out_file.puts line unless <put here your condition for removing the line>
  end
end
