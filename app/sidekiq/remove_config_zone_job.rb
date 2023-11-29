class RemoveConfigZoneJob
    include Sidekiq::Job
  
    def perform(zone_id)
        zone = Zone.find(zone_id)
        remove_configurations(zone)
        zone.destroy
    end
  
    private
  
    def remove_configurations(zone)
      remove_zone_from_file('/etc/bind/named.conf.local', zone.name)
      remove_zone_from_file('/etc/bind/named.conf.options', zone.name)
      remove_zone_folder(zone)
    end
  
    def remove_zone_from_file(file_path, name)
      File.open(file_path, 'r+') do |file|
        content = file.read
  
        #for /etc/bind/named.conf.local
        content.gsub!(/zone "#{name}" \{\n\t type master;\n\t file "\/etc\/bind\/#{name}\/db\.rpz\.#{name}";\n\};\n/, '')
        
        #for /etc/bind/named.conf.options
        content.gsub!(/\t zone "#{name}";\n/, '')
  
        file.rewind
        file.write(content)
        file.truncate(file.pos)
      end
    end
    
    def remove_zone_folder(zone)
      feed_zones = FeedZone.where(zone_id: zone.id)
      feed_zones.each do |feed_zone|
        file_path = feed_zone.file_path
        if File.exist?(file_path)
          system("sudo rm #{file_path}")
        end
        feed_zone.destroy
      end
      custom_blacklists = CustomBlacklist.where(zone_id: zone.id)
      custom_blacklists.each do |custom_blacklist|
        custom_blacklist.destroy
      end

      folder_path = "/etc/bind/#{zone.name}"
      if File.directory?(folder_path)
        system("sudo rm -r #{folder_path}")
      end
    end
  end
  