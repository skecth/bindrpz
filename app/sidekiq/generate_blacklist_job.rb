class GenerateBlacklistJob
  include Sidekiq::Job

  def perform(*args)
    zones = Zone.all
    custom_blacklists = CustomBlacklist.all

    zones.each do |zone|
      rule = zone.name
      custom_blacklists_for_zone = custom_blacklists.where(zone_id: zone.id)

      custom_blacklists_for_zone.each do |custom_blacklist|
        domain = custom_blacklist.domain
        action = custom_blacklist.action
        destination = custom_blacklist.destination

        blacklist_file = custom_blacklist.zone.zone_path
        blacklist_rule = "#{domain}.#{rule}. #{action} #{destination}; \n"
        lines = File.readlines(blacklist_file)

        # find line that contains the domain and delete it
        lines.reject! { |line| line.include?(domain) }
        Rails.logger.info "Removed #{domain} from #{blacklist_file}"


        unless lines.include?(blacklist_rule)
          lines << blacklist_rule
          File.write(blacklist_file, lines.join)
        end
        Rails.logger.info "Added #{blacklist_rule} to #{blacklist_file}"



      end
    end
  end
end
