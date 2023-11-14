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
      if File.directory?(zone.zone_path)
        system("sudo rm -r #{zone.zone_path}")
      end
    end
  end
  