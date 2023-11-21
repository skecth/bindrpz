class RemoveBlacklistJob
  include Sidekiq::Job

  def perform(custom_blacklist_id)
    custom_blacklist = CustomBlacklist.find(custom_blacklist_id)
    zone = custom_blacklist.zone
    rule = zone.name
    domain = custom_blacklist.domain
    action = custom_blacklist.action
    destination = custom_blacklist.destination

    blacklist_file = zone.zone_path
    blacklist_rule = "#{domain}.#{rule}. #{action} #{destination}; \n"
    lines = File.readlines(blacklist_file)

    if lines.include?(blacklist_rule)
      lines.delete(blacklist_rule)
      File.open(blacklist_file, 'w') do |file|
        file.write(lines.join)
      end

      Rails.logger.info "Removed #{blacklist_rule} from #{blacklist_file}"
    end

    custom_blacklist.destroy
  end
end