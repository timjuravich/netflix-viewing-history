#!/usr/bin/env ruby
require 'date'
require 'net/http'
require 'json'
require 'uri'
require './lib/utils.rb'

# Config
METADATA_OUTPUT      = File.dirname(__FILE__) + "/output/metadata-output.txt"

stats_dataset = Utils::load_metadata()

# Total items watched
total_items_watched = stats_dataset.size
total_movies_watched = stats_dataset.select {|row| row[:type] == "movie" }.size
total_shows_watched = stats_dataset.select {|row| row[:type] == "series" }.size

# Get watch times
minutes_watching = stats_dataset.map {|row| row[:runtime].to_i}.reduce(0, :+)
hours_watching = minutes_watching / 60
days_watching = hours_watching / 24

# Firsts
first_day = stats_dataset.sort_by { |row| row[:date] }.first[:date]
last_day = stats_dataset.sort_by { |row| row[:date] }.last[:date]
days_on_netflix = (last_day - first_day).to_i
total_potential_hours = days_on_netflix * 24
watch_hour_percentage = (hours_watching.to_f / total_potential_hours.to_f) * 100.0

puts "date of first item watch: #{first_day}"
puts "date of last item watch: #{last_day}"
puts "days on netflix: #{days_on_netflix}"
puts "total potential hours: #{total_potential_hours}"
puts "minutes watching: #{minutes_watching}"
puts "hours watching: #{hours_watching}"
puts "days watching: #{days_watching}"
puts "percentage of all time watching netflix: #{watch_hour_percentage}"
puts "number of total things: #{total_items_watched}"
puts "total movies watched: #{total_movies_watched}"
puts "total tv shows watched: #{total_shows_watched}"
puts "items needing triage: #{stats_dataset.select {|row| row[:triage] == "true" }.size}"
