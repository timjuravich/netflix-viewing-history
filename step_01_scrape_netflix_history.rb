#!/usr/bin/env ruby
require 'iconv'
require 'nokogiri'
require 'date'
require './lib/utils.rb'

# Config
NETFLIX_LIST_URL     = 'https://www.netflix.com/WiViewingActivity?'
PAGE_LOAD_WAIT       = 2
LAST_SCRAPED_DATE    = Utils::get_last_scraped_date
ICONV                = Iconv.new('UTF-8//IGNORE', 'UTF-8')

def get_netflix_info(html)
  watch_array = []
  page = Nokogiri::HTML(html)
  page.xpath('//ul[contains(@class, "retable")]//li').each do |row|
   date=row.xpath('.//div[@class="col date nowrap"]').text.strip
   title=row.xpath('.//div[@class="col title"]').text.strip
   url=row.xpath('.//div[@class="col title"]//a/@href')
   str="#{date};#{title};#{url}"
   break if Date.strptime(date, "%m/%d/%") <= LAST_SCRAPED_DATE
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
      repeat 10 times
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

netflix_watch_array = get_netflix_info(get_netflix_list_html(NETFLIX_LIST_URL))
# Write out netflix values
File.open(NETFLIX_RAW_OUTPUT, "w") do |file|
  netflix_watch_array.each do |line|
   file.puts "#{line}"
  end
end
