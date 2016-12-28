#!/usr/bin/env ruby
require 'iconv'
require 'nokogiri'
require 'date'

# Config
NETFLIX_LIST_URL     = 'https://www.netflix.com/WiViewingActivity?'
PAGE_LOAD_WAIT  = 2
START_TIME      = Date.parse('2009-09-06') # When I started using netflix
NETFLIX_RAW_OUTPUT  = File.dirname(__FILE__) + "/output/netflix-raw.txt"

# Character encoding converter instance used to force all HTML output into UTF-8 format
ICONV           = Iconv.new('UTF-8//IGNORE', 'UTF-8')

def get_netflix_info(html)
  watch_array = []
  page = Nokogiri::HTML(html)
  page.xpath('//ul[contains(@class, "retable")]//li').each do |row|
   date=row.xpath('.//div[@class="col date nowrap"]').text.strip
   title=row.xpath('.//div[@class="col title"]').text.strip
   url=row.xpath('.//div[@class="col title"]//a/@href')
   str="#{date};#{title};#{url}"
   puts str
   watch_array << str
  end
  watch_array
end

# Obtain the HTML source for the given URL
def get_netflix_list_html(url)
  applescript = <<-EOF
    tell application "Safari"
      activate
      set url of document 1 to "#{url}"
      delay #{PAGE_LOAD_WAIT}
      repeat 4 times
        tell application "System Events" to key code 125 using option down
        delay .2
      end repeat
    end tell
    tell application "Safari"
      activate
      set htmlSource to do JavaScript "document.body.innerHTML" in document 1
      set the clipboard to htmlSource as text
    end tell
  EOF
  ICONV.iconv(`osascript -e '#{applescript}' && pbpaste` + ' ')[0..-2]
end

# If file doesn't exist, scrape and write it
if !File.exist?(NETFLIX_RAW_OUTPUT)
  netflix_watch_array = get_netflix_info(get_netflix_list_html(NETFLIX_LIST_URL))
  # Write out netflix values
  File.open(NETFLIX_RAW_OUTPUT, "w") do |file|
    netflix_watch_array.each do |line|
     file.puts "#{line}"
    end
  end
end

# Read file into a hash

# For each day from start date until now
(START_TIME..Date.today).each do |date|

  puts date
end
