#!/usr/bin/env ruby
require 'date'
require 'net/http'
require 'json'
require 'uri'
require './lib/utils.rb'

stats_dataset = Utils::load_metadata()
metrics = []

def add_metric(metrics, metric, value)
  puts "#{metric}: #{value}"
  metrics.push({:metric => metric, :value => value})
end

# Total Breakdowns
add_metric(metrics, "Total Things Watched", stats_dataset.select {|row| row[:runtime] != ''}.size)
add_metric(metrics, "Total Movies Watched", stats_dataset.select {|row| row[:type] == "movie" }.size)
add_metric(metrics, "Total Shows Watched", stats_dataset.select {|row| row[:type] == "series" }.size)
add_metric(metrics, "Total Series Watched", stats_dataset.uniq! {|row| row[:series_title] }.size - stats_dataset.select {|row| row[:type] == "movie" }.size)

# Get watch times
minutes_watched = stats_dataset.map {|row| row[:runtime].to_i}.reduce(0, :+)
add_metric(metrics, "Minutes Watched", minutes_watched)
add_metric(metrics, "Hours Watched", minutes_watched / 60)
add_metric(metrics, "Days Watched", (minutes_watched / 60) / 24)

# Overview
first_watch = stats_dataset.sort_by { |row| row[:date] }.first[:date]
last_watch = stats_dataset.sort_by { |row| row[:date] }.last[:date]
days_on_netflix = (last_watch - first_watch).to_i
hours_on_netflix = days_on_netflix * 24

add_metric(metrics, "First Watch", first_watch)
add_metric(metrics, "Last Watch", last_watch)
add_metric(metrics, "Years On Netflix", (days_on_netflix / 365.0).to_f)
add_metric(metrics, "Days On Netflix", days_on_netflix)
add_metric(metrics, "Hours On Netflix", hours_on_netflix)
add_metric(metrics, "Percentage Of All Time", ((minutes_watched / 60).to_f / hours_on_netflix.to_f) * 100.0)

# Assumes the average person sleeps 8 hours at night and works 8 hours at day
add_metric(metrics, "Percentage Of A Normal Sleepers Time", ((minutes_watched / 60).to_f / (days_on_netflix * 8).to_f) * 100.0)


first_day = stats_dataset.sort_by { |row| row[:date] }.first[:date]
last_day = stats_dataset.sort_by { |row| row[:date] }.last[:date]

daily_time_series = []

max_streak = { :start => nil, :end => nil, :streak => 0 }
current_streak = nil

# Daily Time Series
first_day.upto(last_day) do |date|
  puts date.to_s
  watches_on_date = stats_dataset.select {|row| row[:date] == date }
  minutes_watched = watches_on_date.map {|row| row[:runtime].to_i}.reduce(0, :+)

  if minutes_watched > 0
    if current_streak.nil?
      puts "- start streak"
      current_streak = { :start => date }
    end
  else
    if !current_streak.nil?
      puts "--- end streak"
      # get the length
      streak_length = (date - current_streak[:start]).to_i

      if streak_length > max_streak[:streak]
        puts "------- new record: #{streak_length}"
        max_streak = { :start => current_streak[:start], :end => date, :streak => streak_length}
      end

      current_streak = nil
    end
  end
end

add_metric(max_streak, "Highest Streak Of Days In A Row", max_streak)

# Weekly Averages
  # Sunday: average watch times
  # Monday: average watch times
  # Tuesday: average watch times
  # Wednesday: average watch times
  # Thursday: average watch times
  # Friday: average watch times
  # Saturday: average watch times

  # Sunday: total watch times
  # Monday: total watch times
  # Tuesday: total watch times
  # Wednesday: total watch times
  # Thursday: total watch times
  # Friday: total watch times
  # Saturday: total watch times

  # Sunday: % of total
  # Monday: % of total
  # Tuesday: % of total
  # Wednesday: % of total
  # Thursday: % of total
  # Friday: % of total
  # Saturday: % of total

# puts "date of first item watch: #{first_day}"
# puts "date of last item watch: #{last_day}"
# puts "days on netflix: #{days_on_netflix}"
# puts "total potential hours: #{total_potential_hours}"
# puts "minutes watching: #{minutes_watching}"
# puts "hours watching: #{hours_watching}"
# puts "days watching: #{days_watching}"
# puts "percentage of all time watching netflix: #{watch_hour_percentage}"
# puts "number of total things: #{total_items_watched}"
# puts "total movies watched: #{total_movies_watched}"
# puts "total tv shows watched: #{total_shows_watched}"
# puts "total series watched: #{total_series_watched}"
# puts "items needing triage: #{stats_dataset.select {|row| row[:triage] == "true" }.size}"

File.open(METRICS_OUTPUT, "w") do |file|
  file.puts "Metric,Value"
  metrics.each do |row|
   file.puts "#{row[:metric]},#{row[:value]}"
  end
end
