#!/usr/bin/env ruby
require 'date'
require 'net/http'
require 'json'
require 'uri'
require './lib/utils.rb'

blacklist = ['Mouk', 'Sofia the First', 'Sarah & Duck']
clean_data = []

File.open(METADATA_OUTPUT, "r").each_with_index do |line, index|
  row = line.chomp("\n")
  data = row.split(/\;/)
  if !blacklist.include?(data[14])
    clean_data.push(row)
  else
    puts "Remove: #{row}"
  end
end

File.open(METADATA_OUTPUT, "w") do |file|
  clean_data.each do |row|
    file.puts "#{row}"
  end
end
