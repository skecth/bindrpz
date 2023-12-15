require 'fileutils'

class ZonesController < ApplicationController
  before_action :set_zone, only: %i[ show edit update destroy ]

  # GET /zones or /zones.json
  def index
    @zones = Zone.all
  end

  # GET /zones/1 or /zones/1.json
  def show
    @zones = Zone.all
    @zone = Zone.find(params[:id])
    @feed_zones = FeedZone.all.where(zone_id: @zone.id) 
    puts "feed zone: #{@feed_zones.count}"
    @feed_zones = @zone.feed_zones
    @zone = Zone.find(params[:id])
    # puts @feed_zones
    @custom_blacklists = CustomBlacklist.all.where(zone_id: @zone.id)

  end

  # GET /zones/new
  def new
    @zone = Zone.new
  end

  # GET /zones/1/edit
  def edit
    @category = Category.all
    @zone =  Zone.find(params[:id])
    @zone_id = @zone.name
    puts "zone: #{@zone_id}"
    saved_feed_ids = FeedZone.pluck(:feed_id)
    # Filter available Feed records to exclude saved feed_ids
    @available_feeds = Feed.where.not(id: saved_feed_ids)


  end

  # POST /zones or /zones.json
  def create
    @zone = Zone.new(zone_params)
    
    respond_to do |format|
      if @zone.save
        format.html { redirect_to zones_path, notice: "Zone was successfully created." }
        format.json { render :show, status: :created, location: @zone }
        #add job @zone to config zone
        #ConfigZoneJob.perform_async
        zones = Zone.all

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

      else
        format.turbo_stream { render partial: "zones/form_update", status: :unprocessable_entity }

      end
    end
  end


  # PATCH/PUT /zones/1 or /zones/1.json
  def update
    feed_zones_attributes = params[:zone][:feed_zones_attributes] # Ensure the correct nesting
    puts "feed_zones_attributes: #{feed_zones_attributes}"
    file_path = feed_zones_attributes.values.first['file_path']
   
    existing_feed_ids = []

    # Loop through the feed_zones_attributes to filter out duplicate feed_ids
    feed_zones_attributes.each do |_key, attributes|
      feed_id = attributes['feed_id']
      unless existing_feed_ids.include?(feed_id)
        existing_feed_ids << feed_id
      else
        # Remove the duplicate feed_id from the params
        feed_zones_attributes.delete(_key)
      end
    end
  
    respond_to do |format|
      if @zone.update(zone_params)
        format.html { redirect_to zone_path, notice: "Zone was successfully updated." }
        format.json { render :show, status: :ok, location: @zone }
        #GenerateRpzJob.perform_async
        generate_rpz
        include_feed_zone_in_zone_path(file_path)
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "zones/nested_feed_zone_create", status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zones/1 or /zones/1.json
  def destroy
    zone = Zone.find(@zone.id)
    remove_configurations(zone)
    zone.destroy

    respond_to do |format|
      format.html { redirect_to zones_path, notice: "Zone was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_zone
      @zone = Zone.find(params[:id])
    end

  

    # Only allow a list of trusted parameters through.
    def zone_params
      params.require(:zone).permit(:name,
                                   :zone_path,
                                   :description,
                                   feed_zones_attributes: [:id, :feed_id, :destination,:file_path,:selected_action,:_destroy]
      )          
    end

    # def to include feed_zone in zone_path
    def include_feed_zone_in_zone_path(file_path)
      @zone = Zone.find(params[:id])
      @feed_zones = FeedZone.all.where(zone_id: @zone.id, enable_disable_status: true)
      @feed_zones.each do |feed_zone|
        file_path = feed_zone.file_path
        include_feed_zone(file_path)
      end
    end
    
    def include_feed_zone(file_path)
      #add $INCLUDE of every file_path in zone_path
      rpz_rule = "$INCLUDE #{file_path};\n"
      lines = File.readlines(@zone.zone_path).map(&:strip)
    
      unless lines.include?(rpz_rule.strip)
        File.open(@zone.zone_path, 'a') do |file|
          file.write(rpz_rule)
        end
        Rails.logger.info "Added #{rpz_rule} to #{@zone.zone_path}"
      end
    end

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
        #system("sudo mkdir #{zone_path}")
        FileUtils.mkdir_p(zone_path)
      end

      zone_file = "#{zone_path}/db.rpz.#{zone.name}"
      template_path = "/etc/bind/db.empty"
      
      # Create file if not exist
      unless File.exist?(zone_file)
        #system("sudo cp #{template_path} #{zone_file}")
        FileUtils.cp(template_path, zone_file)
      end

      #system("sudo chmod 777 #{zone_file}")
      File.chmod(0777, zone_file)

      zone.update(zone_path: zone_file)
    end

    #def to generate feedzone
    def generate_rpz
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
              #system("sudo touch #{feed_path}")
              FileUtils.touch(feed_path)
            end

            #system("sudo chmod 777 #{feed_path}")
            File.chmod(0777, feed_path)

            File.open(feed_path, 'w') do |file|
              file.write("$INCLUDE #{feed_path}; \n")
            end

            # Read the file
            domain_names = File.read(file_path, encoding: 'UTF-8').split("\n")
            domain_names.each do |domain_name|
              #domain_rule = "#{domain_name}.#{rule}. #{action} #{destination}"
              # If the domain name is an IP address without a range
              if domain_name =~ /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/
                ip = domain_name.split('.').reverse.join('.')
                domain_name = "32.#{ip}"
              # If the domain name is an IP address with a range
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

            # Write the file
            File.open(feed_path, 'w') do |file|
              file.write(feed_rules.join("\n"))
            end
          end
        end
      end
    end

    #remove rpz confiigurations
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
          #system("sudo rm #{file_path}")
          FileUtils.rm(file_path)
        end
        feed_zone.destroy
      end
      custom_blacklists = CustomBlacklist.where(zone_id: zone.id)
      custom_blacklists.each do |custom_blacklist|
        custom_blacklist.destroy
      end

      folder_path = "/etc/bind/#{zone.name}"
      if File.directory?(folder_path)
        #system("sudo rm -r #{folder_path}")
        FileUtils.rm_rf(folder_path)
      end
    end
end
