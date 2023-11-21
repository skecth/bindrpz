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

        unless lines.include?(blacklist_rule)
          File.open(blacklist_file, 'a') do |file|
            file.write(blacklist_rule)
          end
        end
        Rails.logger.info "Added #{blacklist_rule} to #{blacklist_file}"

      end
    end
  end
end
