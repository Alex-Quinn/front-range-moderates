#!/usr/bin/env ruby

require 'csv'
require 'fileutils'

BOULDER_CSV_DATA_PATH = "./_app/_data/front_range_moderates.csv"
BOULDER_POSTS_GLOB = "./_app/_posts/boulder/*.md"

# Delete all existing posts
puts "Deleting all existing posts..."
FileUtils.rm(Dir.glob(BOULDER_POSTS_GLOB))
puts "Done deleting all existing posts..."

# For each entry in the CSV, create a post
puts "Creating posts for each boulder in database..."

boulder_data = CSV.open(BOULDER_CSV_DATA_PATH, headers: :first_row).map(&:to_h)
sorted = boulder_data.sort_by do |d|
  [d["Grade"].tr("V", "").to_i, d["Location"], d["Name"]]
end.reverse

time_for_file_name = Time.at(0)
sorted.each.with_index do |info, i|
  puts "   - #{info["Name"]}"

  sanitized_name = info["Name"].gsub(/\.|'|"|\(|\)/, "").tr(" ", "-").downcase

  # To make sure boulders show up in order, hack together dates in ascending order
  time_for_file_name += 86400
  file_name = "#{time_for_file_name.strftime("%Y-%m-%d")}-#{sanitized_name}.md"
  file_path = "_app/_posts/boulder/#{file_name}"

  contents = <<-TEMPLATE
---
layout: boulder
category: boulder

title: #{info["Name"]}
grade: #{info["Grade"]}
location: #{info["Location"]}
tags:
  - #{info["Grade"].downcase}
  - #{info["Location"].tr(" ", "_").downcase}
---

## Description
#{info["Description"]}

## More Info
#{info["More Info"]}
  TEMPLATE

  File.open(file_path, "w+") do |f|
    f.write(contents)
  end
end

puts
puts "Done!"
