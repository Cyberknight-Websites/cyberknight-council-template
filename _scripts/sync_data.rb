require 'open-uri'
require 'json'
require 'optparse'
require 'rmagick'
require 'tzinfo'

begin
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: sync_data.rb [options]"

    opts.on("-c", "--council COUNCIL_NUMBER", "Council number") do |c|
      options[:council_number] = c
    end

    opts.on("-u", "--url KOC_URL", "Kocp URL") do |u|
      options[:kocp_url] = u
    end
  end.parse!

  council_number = options[:council_number] || 2431
  kocp_url = options[:kocp_url] || "http://127.0.0.1"

  all_council_info_api_url = "#{kocp_url}/public_api/get_all_council_info/#{council_number}"
  all_council_info_api_response = URI.open(all_council_info_api_url).read
  all_council_info_data = JSON.parse(all_council_info_api_response)
  File.open("_data/all_council_info_data.json", "w") do |f|
    f.write(all_council_info_data.to_json)
  end

  puts "Synced all council #{council_number} data to _data/all_council_info_data.json"

  def escape_html_for_yaml(content)
    return '""' if content.nil? || content.empty?
    escaped = content.gsub('"', '\\"')  # Escape double quotes
    "\"#{escaped}\""
  end

  Dir.mkdir('_events') unless Dir.exist?('_events')
  # Delete existing event files
  Dir.glob('_events/*.md').each { |file| File.delete(file) }
  all_council_info_data['council_events'].each do |event|
    filename = "_events/#{event['event_id'].downcase.gsub(' ', '_')}.md"
    File.open(filename, 'w') do |file|
      file.puts "---"
      file.puts "layout: event"
      file.puts "title: #{escape_html_for_yaml(event['event_name'])}"
      file.puts "event_name: #{escape_html_for_yaml(event['event_name'])}"
      file.puts "event_description: #{escape_html_for_yaml(event['event_description'])}"
      file.puts "event_details: #{escape_html_for_yaml(event['event_details'])}"
      file.puts "event_start_time: #{event['event_start_time']}"
      file.puts "event_end_time: #{event['event_end_time']}"
      file.puts "video_call_url: #{escape_html_for_yaml(event['video_call_url'])}"
      file.puts "timezone: #{escape_html_for_yaml(event['timezone'])}"
      file.puts "calendar_link: #{escape_html_for_yaml(event['calendar_link'])}"
      file.puts "location_name: #{escape_html_for_yaml(event['location_name'])}"
      file.puts "location_address: #{escape_html_for_yaml(event['location_address'])}"
      file.puts "location_gps_coordinates_lat: #{event['location_coordinates'][0]}"
      file.puts "location_gps_coordinates_lon: #{event['location_coordinates'][1]}"
      file.puts "event_last_updated: #{event['event_last_updated']}"
      file.puts "---"
    end
  end

  puts "Generated #{all_council_info_data['council_events'].length} event files in _events directory"

  website_tz = "US/Pacific"
  tz = TZInfo::Timezone.get(website_tz)

  Dir.mkdir('_posts') unless Dir.exist?('_posts')
  # Delete existing post files
  Dir.glob('_posts/*.md').each { |file| File.delete(file) }
  all_council_info_data['council_posts'].each do |post|
    post_edit_log = post['post_edit_log']
    post_created_at_unixtime = post_edit_log[0]['edit_time']
    post_created_at_localized = tz.to_local(Time.at(post_created_at_unixtime))
    post_created_by = post_edit_log[0]['member_name']
    post_last_edited_at_unixtime = post_edit_log[-1]['edit_time']
    post_last_edited_at_localized = tz.to_local(Time.at(post_last_edited_at_unixtime))
    post_last_edited_by = post_edit_log[-1]['member_name']
    
    filename = "_posts/#{post_created_at_localized.strftime('%Y-%m-%d')}-#{post['post_title'].downcase.gsub(' ', '_')}.md"
    File.open(filename, 'w') do |file|
      file.puts "---"
      file.puts "layout: post"
      file.puts "title: \"#{post['post_title']}\""
      file.puts "description: \"#{post['post_description']}\""
      file.puts "permalink: /posts/:year/:month/:slug"
      file.puts "post_created_at: #{post_created_at_unixtime}"
      file.puts "post_created_by: \"#{post_created_by}\""
      file.puts "post_last_edited_at: #{post_last_edited_at_unixtime}"
      file.puts "post_last_edited_by: \"#{post_last_edited_by}\""
      file.puts "---"
      file.puts post['post_body'].gsub("<p><br></p>", "<p></p>")
    end
  end

  puts "Generated #{all_council_info_data['council_posts'].length} post files in _posts directory"

  # Process announcements
  Dir.mkdir('_announcements') unless Dir.exist?('_announcements')
  # Delete existing announcement files
  Dir.glob('_announcements/*.md').each { |file| File.delete(file) }
  if all_council_info_data.key?('council_announcements') && !all_council_info_data['council_announcements'].empty?
    all_council_info_data['council_announcements'].each do |announcement|
      filename = "_announcements/#{announcement['announcement_id']}.md"
      
      # Create announcement markdown file
      File.open(filename, 'w') do |file|
        file.puts "---"
        file.puts "layout: announcement"
        file.puts "announcement_id: #{announcement['announcement_id']}"
        file.puts "announcement_types: #{announcement['announcement_types'].to_json}"
        file.puts "sent_at: #{announcement['sent_at']}"
        
        # Include email content if it exists
        if announcement['announcement_types'].include?('email')
          file.puts "title: #{escape_html_for_yaml(announcement['email_subject'])}"
          file.puts "email_subject: #{escape_html_for_yaml(announcement['email_subject'])}"
          file.puts "email_body: #{escape_html_for_yaml(announcement['email_body'])}"
          # check that email_attachment_urls exists and handle the new structure
          if announcement['email_attachment_urls'] && !announcement['email_attachment_urls'].empty?
            file.puts "email_attachment_urls: #{announcement['email_attachment_urls'].to_json}"
          end
        else
          file.puts "title: Council Announcement"
        end
        
        # Include SMS content if it exists
        if announcement['announcement_types'].include?('sms')
          file.puts "sms_body: #{escape_html_for_yaml(announcement['sms_body'])}"
        end
        
        file.puts "---"
      end
    end
    puts "Generated #{all_council_info_data['council_announcements'].length} announcement files in _announcements directory"
  else
    puts "No announcements found in API response"
  end

  Dir.mkdir('assets/opengraph') unless Dir.exist?('assets/opengraph')

  homepage_opengraph = Magick::Image.read('assets/opengraph/opengraph-website-title-template.png').first
  draw_text = Magick::Draw.new
  draw_text.font = 'assets/fonts/RobotoSlab-Bold.ttf'
  draw_text.gravity = Magick::CenterGravity
  draw_text.fill = '#112764'
  text_to_draw = 'Alhambra Council'
  if text_to_draw.length > 34
    draw_text.pointsize = 28
  elsif text_to_draw.length > 28
    draw_text.pointsize = 32
  elsif text_to_draw.length > 22
    draw_text.pointsize = 40
  else
    draw_text.pointsize = 50
  end
  draw_text.annotate(homepage_opengraph, 0, 0, 0, 70, text_to_draw)

  puts "Generated site opengraph image with title: #{text_to_draw}"

  homepage_opengraph.write('assets/opengraph/opengraph-website-title.png')

rescue StandardError => e
  puts "An error occurred: #{e.message}"
end