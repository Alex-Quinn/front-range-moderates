#!/usr/bin/env ruby

require 'csv'
require 'fileutils'
require 'google/apis/sheets_v4'
require 'googleauth'

BOULDER_POSTS_GLOB = "./_app/_posts/boulder/*.md"
GOOGLE_CREDS = "./.google_api_credentials.json"
GOOGLE_SHEET_ID = "1aQ7KqfP4WtaChjEm9pzzSl-gzgV85KD75qp6uzEGWBI"
GOOGLE_SHEET_RANGE = 'Master List!A1:F'

module ImportBoulders
  def self.run
    # Delete all existing posts
    puts "Deleting all existing posts..."
    FileUtils.rm(Dir.glob(BOULDER_POSTS_GLOB))
    puts "Done deleting all existing posts..."

    # Fetching boulder data
    puts "Fetching boulder data from Google..."
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(GOOGLE_CREDS),
      scope: ['https://www.googleapis.com/auth/spreadsheets.readonly']
    )
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = authorizer
    keys, *values = service.get_spreadsheet_values(
      GOOGLE_SHEET_ID,
      GOOGLE_SHEET_RANGE,
    ).values
    rows = values.map { |row| Hash[keys.zip(row)] }
    boulder_data = rows.select do |row|
      !row["Name"].nil? && row["Name"] != ""
    end

    # For each entry in the CSV, create a post
    puts "Creating posts for each boulder in database..."
    sorted = boulder_data.sort_by do |d|
      [d["Grade"].tr("V", "").to_i, d["Location"], d["Name"]]
    end.reverse

    time_for_file_name = Time.at(0)
    sorted.each.with_index do |info, i|
      name = info["Name"]
      grade = info["Grade"]
      location = info["Location"]
      description = info["Description"]
      more_info = info["More Info"]
      photo_link = info["Photo"]
      full_page = (!description.nil? && description.length > 0) || !photo_link.nil?

      puts "   - #{name}"

      content = ImportBoulders.content_str(name, grade, location, description, more_info, photo_link, full_page)

      # To make sure boulders show up in order, hack together dates in ascending order
      time_for_file_name += 86400
      sanitized_name = name.gsub(/\.|'|"|\(|\)/, "").tr(" ", "-").downcase
      file_name = "#{time_for_file_name.strftime("%Y-%m-%d")}-#{sanitized_name}.md"
      file_path = "_app/_posts/boulder/#{file_name}"

      File.open(file_path, "w+") do |f|
        f.write(content)
      end
    end

    puts
    puts "Done!"
  end

  def self.content_str(name, grade, location, description, more_info, photo_link, full_page)
<<-CONTENT
---
layout: boulder
category: boulder

title: #{name}
grade: #{grade}
location: #{location}
tags:
- #{grade.downcase}
- #{location.tr(" ", "_").downcase}
full_page: #{full_page}
---
#{ImportBoulders.photo_str(photo_link)}

Description
{: .largetype}
#{description}

More Info
{: .largetype}
#{more_info}
CONTENT
  end

  def self.photo_str(photo_link)
    return "" if photo_link.nil?
<<-IMG_STR

![Image](#{photo_link}){: .size-small}

---
IMG_STR
  end
end

ImportBoulders.run
