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
sorted = boulder_data.reject { |d| d["Name"].nil? }.sort_by do |d|
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

  more_info = info["More Info"]
  more_info_str =
    if more_info =~ /\.com/
      "[#{more_info}](#{more_info}){:target=\"_blank\"}"
    else
      more_info
    end

  desc_str = info["Description"]
  full_page = !desc_str.nil? && desc_str.length > 0

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
full_page: #{full_page}
---

## Description
#{desc_str}

## More Info
#{more_info_str}
  TEMPLATE

  File.open(file_path, "w+") do |f|
    f.write(contents)
  end
end

puts
puts "Done!"
