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

        # Iterate over each file path
        file_paths.each do |file_path|
          # make sure the file exists
          if File.exist?(feed_path) && File.exist?(file_path)
            # Read the file
            existing_domains = File.read(feed_path, encoding: 'UTF-8').split("\n")
            new_domains = File.read(file_path, encoding: 'UTF-8').split("\n")

            domain_names = new_domains - existing_domains

            domain_names.each do |domain_name|
              domain_rule = "#{domain_name}.#{rule}. #{action.first} #{destination.first}"
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