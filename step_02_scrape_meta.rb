#!/usr/bin/env ruby
require 'date'
require 'net/http'
require 'json'
require 'uri'
require './lib/utils.rb'

# Config
SLEEP_TIME           = 2

raw_data = Utils::load_raw_data().reverse
series_data = []
existing_series = []

raw_data.each_with_index do |row, index|
  puts "---------------"

  potential_series_title = row[:title].split(":").first

  existing_series = series_data.find {|r| r[:series_title] == potential_series_title}

  if existing_series
    puts "Cache Hit: Use series data".green
    # use its data and skip
    raw_data[index] = row.merge(existing_series)
    puts raw_data[index].to_s.colorize(:green)
  else
    # it doesnt exist, go get it
    puts "Cache Miss: Get new data".red
    scraped_data = Utils::get_movie_meta(row)

    # put the data into a series data array for future use
    series_data << scraped_data

    # inject the scraped data into the original raw data source
    raw_data[index] = row.merge(scraped_data)
    puts raw_data[index].to_s.colorize(:light_blue)

    sleep(SLEEP_TIME)
  end
end

write_method = "a"

if !File.exist?(METADATA_OUTPUT)
  write_method = "w"
end

File.open(METADATA_OUTPUT, write_method) do |file|
  if !File.exist?(METADATA_OUTPUT)
    file.puts "Date;Title;URL;Source;Type;Runtime;Year;Rated;Released;Genre;Director;Actors;Rating;IMDB ID;Series Title;Triage"
  end

  raw_data.each do |row|
   file.puts "#{row[:raw]};Netflix;#{row[:type]};#{row[:runtime]};#{row[:year]};#{row[:rated]};#{row[:released]};#{row[:genre]};#{row[:director]};#{row[:actors]};#{row[:rating]};#{row[:imdb_id]};#{row[:series_title]};#{row[:triage]}"
  end
end
