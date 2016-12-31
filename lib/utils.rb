#!/usr/bin/env ruby
require 'date'
require 'net/http'
require 'json'
require 'uri'
require 'date'

NETFLIX_RAW_OUTPUT        = File.dirname(__FILE__) + "/../output/netflix-history-raw.txt"
METADATA_OUTPUT           = File.dirname(__FILE__) + "/../output/metadata-output.txt"
DAILY_TIMESERIES_OUTPUT   = File.dirname(__FILE__) + "/../output/daily-timeseries-output.txt"

class Utils

  def self.get_last_scraped_date
    metadata = load_metadata
    metadata.last[:date]
  end

  def self.meta_hash_from_string(data)
    {
      :date         => Date.strptime(data[0], '%m/%d/%y'),
      :title        => data[1],
      :url          => data[2],
      :source       => data[3],
      :type         => data[4],
      :runtime      => data[5],
      :year         => data[6],
      :rated        => data[7],
      :released     => data[8],
      :genre        => data[9],
      :director     => data[10],
      :actors       => data[11],
      :rating       => data[12],
      :imdb_id      => data[13],
      :series_title => data[14],
      :triage       => data[15],
      :week         => Date.strptime(data[0], '%W'),
    }
  end

  def self.load_metadata()
    dataset = []
    File.open(METADATA_OUTPUT, "r").each_with_index do |line, index|
      next if index == 0
      row = line.chomp("\n")
      data = row.split(/\;/)
      dataset.push(Utils::meta_hash_from_string(data))
    end
    dataset
  end

  def self.load_raw_data()
    raw_data = []
    File.open(NETFLIX_RAW_OUTPUT, "r").each_with_index do |line, index|
      next if index == 0
      row = line.chomp("\n")
      data = row.split(/\;/)
      raw_data.push({ :raw => row, :title => data[1],:url => "https://www.netflix.com#{data[2]}" })
    end
    raw_data
  end

  def self.get_movie_meta(data)
    title = URI.escape(data[:title].split(":").first)
    uri = URI("http://www.omdbapi.com/?t=#{title}&y=&plot=short&r=json")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response, :symbolize_names => true)

    if json[:Response] == "True"
      { :year         => json[:Year],
        :rated        => json[:Rated],
        :released     => json[:Released],
        :runtime      => json[:Runtime].chomp(" min"),
        :genre        => json[:Genre],
        :director     => json[:Director],
        :actors       => json[:Actors],
        :rating       => json[:imdbRating],
        :type         => json[:Type],
        :series_title => data[:title].split(":").first,
        :imdb_id      => json[:imdbID],
        :triage       => "false"
      }
    else
      { :triage       => "true" }
    end
  end

end
