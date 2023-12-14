require 'fileutils'
class UpdateFeedzoneJob < ApplicationJob
  queue_as :default

  def perform(*args)
    zones = Zone.includes(:feed_zones).all

    zones.each do |zone|
      rule = zone.name
      feed_zones_for_zone = zone.feed_zones

      feed_zones_for_zone.each do |feed_zone|
        file_paths = feed_zone.feed.feed_path.split(',').map(&:strip)
        action = feed_zone.selected_action.split(',').map(&:strip).reject(&:empty?)
        destination = feed_zone.destination.split(',').map(&:strip).reject(&:empty?)
        feed_rules = []
        feed_path = feed_zone.file_path
        
        # Create the file if not exist
        unless File.exist?(feed_path)
          #system("sudo touch #{feed_path}")
          FileUtils.touch(feed_path)
        end
        
        # Change the permission of the file
        #system("sudo chmod 777 #{feed_path}")
        File.chmod(0777, feed_path)

        # Iterate over each file path
        file_paths.each do |file_path|
          # make sure the file exists
          if File.exist?(feed_path) && File.exist?(file_path)
            # Read the file
            existing_domains = File.read(feed_path, encoding: 'UTF-8').split("\n")
            new_domains = File.read(file_path, encoding: 'UTF-8').split("\n")

            domain_names = new_domains - existing_domains

            domain_names.each do |domain_name|
              #domain_rule = "#{domain_name}.#{rule}. #{action} #{destination}"
              #add condition of the domain is ip
              if domain_name =~ /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/
                ip = domain_name.split('.').reverse.join('.')
                domain_name = "32.#{ip}"
              elsif domain_name =~ /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}\z/
                parts = domain_name.split('/')
                ip_parts = parts[0].split('.').reverse
                domain_name = parts[1] + '.' + ip_parts.join('.')
              end

              #check if destination exist
              if destination.first.present?
                domain_rule = "#{domain_name}.#{rule}. #{action.first} #{destination.first}."
              else
                domain_rule = "#{domain_name}.#{rule}. #{action.first}"
              end
              feed_rules << domain_rule
            end
          else
            # Log an error if the file doesn't exist
            Rails.logger.error "File does not exist: #{feed_path} or #{file_path}"
          end
        end

        #no duplicate feed_rules in the feed_path
        feed_rules.uniq!

        # Write the file
        File.open(feed_path, 'w') do |file|
          file.write(feed_rules.join("\n"))
        end
      end
    end
  end
end