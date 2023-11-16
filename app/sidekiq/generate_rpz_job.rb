require 'fileutils'

class GenerateRpzJob
  include Sidekiq::Job

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
            domain_rule = "#{domain_name}.#{rule}. #{action.first} #{destination.first}"
            feed_rules << domain_rule
          end

          # Write the file
          File.open(feed_path, 'w') do |file|
            file.write(feed_rules.join("\n"))
          end
        end
      end
    end
  end
end
