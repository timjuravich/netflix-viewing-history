#!/usr/bin/env ruby
require 'date'
require 'net/http'
require 'json'
require 'uri'
require './lib/utils.rb'

# Config
METADATA_OUTPUT      = File.dirname(__FILE__) + "/output/metadata-output.txt"

def get_records_needing_triage()
  triage_list = []
  File.open(METADATA_OUTPUT, "r").each_with_index do |line, index|
    next if index == 0
    row = line.chomp("\n")
    data = row.split(/\;/)
    if data[15] == "true"
      triage_list.push({ :raw => row, :title => data[1] })
    end
  end
  triage_list
end

triage_list = get_records_needing_triage()
series_data = []
existing_series = []

triage_list.each_with_index do |row, index|
  puts row
  # Utils::get_movie_meta(row)

  # Marvel's Daredevil = Daredevil
  # The Last 5 Years = The Last Five Years
  # Friday Night Lights should be TV show

  # potential_series_title = row[:title].split(":").first
  #
  # existing_series = series_data.find {|r| r[:series_title] == potential_series_title}
  #
  # if existing_series
  #   puts "Cache Hit: Use series data"
  #   # use its data and skip
  #   raw_data[index] = row.merge(existing_series)
  #   puts raw_data[index]
  # else
  #   # it doesnt exist, go get it
  #   puts "Cache Miss: Get new data"
  #   scraped_data = get_movie_meta(row)
  #
  #   # put the data into a series data array for future use
  #   series_data << scraped_data
  #
  #   # inject the scraped data into the original raw data source
  #   raw_data[index] = row.merge(scraped_data)
  #   puts raw_data[index]
  #
  #   sleep(SLEEP_TIME)
  # end
end
