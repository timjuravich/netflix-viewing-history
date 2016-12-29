#!/usr/bin/env ruby
require 'date'
require 'net/http'
require 'json'
require 'uri'
require './lib/utils.rb'

# Config
METADATA_OUTPUT      = File.dirname(__FILE__) + "/output/metadata-output.txt"
TIMESERIES_OUTPUT    = File.dirname(__FILE__) + "/output/timeseries-output.txt"

metadata = Utils::load_metadata()

puts metadata
