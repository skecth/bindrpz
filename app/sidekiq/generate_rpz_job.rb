require 'fileutils'

class GenerateRpzJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform(*args)
    zones = Zone.all
    feed_zones = FeedZone.all

    zones.each do |zone|
      rule = zone.name
      feed_zones_for_zone = feed_zones.where(zone_id: zone.id)

      feed_zones_for_zone.each do |feed_zone|
        file_paths = feed_zone.feed.feed_path.split(',').map(&:strip)
        action = feed_zone.selected_action.split(',').map(&:strip).reject(&:empty?)
        destination = feed_zone.destination.split(',').map(&:strip).reject(&:empty?)

        # Iterate over each file path
        file_paths.each do |file_path|
          feed_rules = []
          feed_path = feed_zone.file_path

          # Create the file if not exist
          unless File.exist?(feed_path)
            system("sudo touch #{feed_path}")
          end

          system("sudo chmod 777 #{feed_path}")

          # Read the file
          domain_names = File.read(file_path, encoding: 'UTF-8').split("\n")
          domain_names.each do |domain_name|
            #domain_rule = "#{domain_name}.#{rule}. #{action} #{destination}"
            #add condition of the domain is ip
            if domain_name =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
              #change the domain name as reverse ip
              domain_name = domain_name.split('.').reverse.join('.')
              domain_rule = "#{domain_name}.#{rule}. #{action.first} #{destination.first}."
            else
              domain_rule = "#{domain_name}.#{rule}. #{action.first} #{destination.first}."
            end
            feed_rules << domain_rule
          end

          # Write the file
          File.open(feed_path, 'w') do |file|
            file.write(feed_rules.join("\n"))
          end

          # include the file in zone file
          rpz_path = zone.zone_path
          rpz_rule = "$INCLUDE #{feed_path}; \n"
          lines = File.readlines(rpz_path)

          unless lines.include?(rpz_rule)
            File.open(rpz_path, 'a') do |file|
              file.write(rpz_rule)
            end
            Rails.logger.info "Added #{rpz_rule} to #{rpz_path}"
          end

        end
      end
    end
  end
end
