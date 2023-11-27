class ConfigZoneJob
    include Sidekiq::Job
  
    def perform
      zones = Zone.all
      system("sudo chmod 777 /etc/bind/named.conf.local")
      system("sudo chmod 777 /etc/bind/named.conf.options")

      File.open('/etc/bind/named.conf.local', 'w') do |file|
        file.write(generate_zones(zones))
      end
  
      File.open('/etc/bind/named.conf.options', 'r+') do |file|
        content = file.read
        content.sub!(/response-policy {(.+?)\};/m, generate_policy(zones))
        file.rewind
        file.write(content)
        file.truncate(file.pos)
      end
  
      zones.each do |zone|
        create_zones_folder(zone)
      end
    end
  
    private
  
    def generate_zones(zones)
      config = ""
      zones.each do |zone|
        config += "zone \"#{zone.name}\" {\n"
        config += "\t type master;\n"
        config += "\t file \"/etc/bind/#{zone.name}/db.rpz.#{zone.name}\";\n"
        config += "};\n"
      end
      config
    end
  
    def generate_policy(zones)
      config = "response-policy {\n"
      zones.each do |zone|
        config += "\t zone \"#{zone.name}\";\n"
      end
      config += "};\n"
      config
    end
  
    #add def to create zones folder
    def create_zones_folder(zone)
      zone_path = "/etc/bind/#{zone.name}"
      if !File.directory?(zone_path)
        system("sudo mkdir #{zone_path}")
      end

      zone_file = "#{zone_path}/db.rpz.#{zone.name}"
      template_path = "/etc/bind/db.empty"
      
      # Create file if not exist
      unless File.exist?(zone_file)
        system("sudo cp #{template_path} #{zone_file}")
      end

      system("sudo chmod 777 #{zone_file}")

      zone.update(zone_path: zone_file)
    end
  
  
  end
  