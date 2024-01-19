require 'fileutils'

class FeedZonesController < ApplicationController
  before_action :set_feed_zone, only: %i[ show edit update destroy]
  # GET /feed_zones or /feed_zones.json
  def index
    @feed_zones = FeedZone.all
    @zones = Zone.all
    @zone = Zone.find(params[:zone_id])
    puts "zone: #{@zone}"
  end

  # GET /feed_zones/1 or /feed_zones/1.json
  def show
    @feed_zones = FeedZone.all
    @zone = Zone.find(params[:id])
    @id = FeedZone.find(params[:id])
  end

  # GET /feed_zones/new
  def new
    @feed_zone = FeedZone.new
    @categories = Category.all
    @zone = Zone.find(params[:id])
    @save_c_id =[]
    @cat = @zone.feed_zones
     
    @feed_category = Category.includes(:feeds).where.not(feeds: { id: nil }).distinct
    @cat.each do |cat|
     puts cat.category_id
    end
    puts "feed: #{@cat}"

    

end
  


  # def feed_upload_check
  #   @zones = Zone.all
  #   @categories = Category.all
  #   @categoryFeed = @categories.select { |cat| cat.feeds.any? }
  #   @zone = Zone.find(params[:id]) 
  #   @feedZone = FeedZone.all

  #   if params[:feed_ids].present?
  #     puts "Feed ids present"
  #     params[:feed_ids].each do |feed_id|
  #       feedID = Feed.find(feed_id)
  #       categoryID = feedID.category_id
  #       category = Category.find(feedID.category_id)

  #       file_zone = "/etc/bind/#{@zone.name}/#{category.name}.rpzfeed"
  #       # Get the selected action and destination for this feed
  #       selected_action = params["feed_#{feed_id}_selected_action"]
  #       feedDestination = params["feed_#{feed_id}_destination"]

  #       if feed_zone.nil?
  #         @feedZone = FeedZone.create(zone_id: @zone.id, feed_id: feed_id, selected_action: selected_action, destination: feedDestination, file_path: file_zone, category_id: categoryID)
  #       else
  #         flash[:alert] ="Feed already exist"
  #       end
  #     end
  #     GenerateRpzJob.perform_async
  #     redirect_to zone_path(@zone)
  #   end
  # end


  
 
  # GET /feed_zones/1/edit
  def edit
    @feeds = Feed.all
    @feed_zone = FeedZone.find(params[:id])
    @feed_id = Feed.find_by(id: @feed_zone.feed_id)
    @category =@feed_zone.category_id
    @feed_name = @feed_id.feed_name
    puts @feed_name
  end

  def pull
    @feedZone = FeedZone.all
    @feedZone.each do |feedzone|
     puts "The url #{feedzone.feed.url}"  
    end
  end

  # POST /feed_zones or /feed_zones.json
    def create
    # @feed_zone = FeedZone.new(feed_zone_params)
    @categories = Category.all
    # @zone = Zone.find(params[:id]) 
    @feedZone = FeedZone.all
    feed_id =params[:feed_id]
    zone=Zone.find_by(id: params[:feed_zone][:zone_id])
    puts "zone id: #{zone.id}"
    if params[:category_ids].present?
      puts "category id exist"
      params[:category_ids].each do |category_id|
        puts "category -1: #{category_id}"
        cat_id = Category.find(category_id)
        puts "category -2: #{cat_id}"
        selected_action = params[:feed_zone]["feed_#{category_id}_selected_action"]
        selected_destination = params[:feed_zone]["feed_#{category_id}_destination"]
        cat_id.feeds.each do |feed|
          existing_feed_zone = FeedZone.find_by(zone_id: zone.id, feed_id: feed.id)
          puts "existing: #{existing_feed_zone}"
          next if existing_feed_zone.present? # Skip if a FeedZone already exists for this feed in the same zone
          feed_name = feed.feed_name
          puts "feed name: #{feed_name}"
          feed_path = "/etc/bind/#{zone.name}/#{feed.feed_name}.rpzfeed"
          # puts "destination: #{selected_destination}"
          # puts "action: #{selected_action}"
          # puts "feed_name: #{feed.feed_name}"
          # puts "feed_path: #{feed_path}"
          # puts "category: #{category_id}"
          # puts "feed_id: #{feed.id}"

          @feed_zone = FeedZone.create(zone_id: zone.id,
                                    selected_action: selected_action, 
                                    destination: selected_destination,
                                    file_path: feed_path,
                                    category_id: category_id,
                                    feed_id: feed.id,
                                    zone_name: zone.name )
        end
      end
      respond_to do |format|
        if @feed_zone.present? 
          if @feed_zone.save
            format.html { redirect_to zone_feed_zones_path(zone.id), notice: "Category was successfully created." }
            format.json { render :show, status: :created, location: @feed_zone }
            generate_rpz
            include_feed_zone_in_zone_path(feed_path)
          else
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @feed_zone.errors, status: :unprocessable_entity }
            format.turbo_stream { render partial: "feed_zones/feed_zone_add", status: :unprocessable_entity }
          end
        else
          format.html { redirect_to zone_feed_zones_path(zone.id), notice: "Feed is already exist in #{zone.name}" }
        end
      end
    end
  end



  def include
    filepath = params[:path]
    id = params[:id]
    @feed_zone = FeedZone.find_by(id: id)
    @feed_zone.update(enable_disable_status: true) 
    #IncludeJob.perform_async(filepath)
    #add def include_job
    include_job(filepath)
    redirect_to zone_feed_zones_path(filepath)
  end

  def exclude
    filepath = params[:path]
    id = params[:id]
    @feed_zone = FeedZone.find_by(id: id)
    @feed_zone.update(enable_disable_status: false)
    #ExcludeJob.perform_async(filepath) 
    #add def exclude_job
    exclude_job(filepath)
    redirect_to zone_feed_zones_path(@feed_zone.zone_id)
  end
 
  # PATCH/PUT /feed_zones/1 or /feed_zones/1.json
  def update
    respond_to do |format|
      if @feed_zone.update(feed_zone_params)
        format.html { redirect_to zone_feed_zones_path(@feed_zone.zone_id), notice: "Feed zone was successfully updated." }
        format.json { render :show, status: :ok, location: @feed_zone }
        generate_rpz
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feed_zone.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "feed_zones/feed_zone_update", status: :unprocessable_entity }
      end
    end
  end
  
  def delete_all
    if params[:feed_zone_ids].present?
      puts "Exist"
    else
      puts "Not exist"
    end
  end

  # DELETE /feed_zones/1 or /feed_zones/1.json
  def destroy
    @id = FeedZone.find(params[:id])
    puts "id: #{@id}"
    #delete file_path
    file_path = @id.file_path
    puts "file path: #{file_path}"
    #ExcludeJob.perform_async(file_path)
    rpz_rule = "$INCLUDE #{file_path};\n"
    zone = @id.zone
    zone_path = zone.zone_path
    puts "zone file: #{zone_path}"
    lines = File.readlines(@id.zone.zone_path)
    if lines.include?(rpz_rule)
      lines.delete(rpz_rule)
      File.open(@id.zone.zone_path, 'w') do |file|
        file.write(lines.join)
      end
      Rails.logger.debug "Removed #{rpz_rule}"
    end

    if File.exist?(file_path)
      #system("sudo rm #{file_path}")
      File.delete(file_path)
    end
    @id.destroy
    respond_to do |format|
      format.html { redirect_to zone_feed_zones_path(@id.zone_id), notice: "Feed zone was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed_zone
      @feed_zone = FeedZone.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feed_zone_params
      params.require(:feed_zone).permit(:selected_action, :destination, :zone_id, :file_path, :category_id, :feed_id, :zone_name)
    end

    def rpz_action(action)
      if action == "NXDOMAIN"
        return "CNAME ."
      end
      action
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

    def include_job(file_path)
      feed_zone = FeedZone.find_by(file_path: file_path)
      if feed_zone
        zone = feed_zone.zone
        rpz_path = zone.zone_path
        rpz_rule = "$INCLUDE #{file_path}; \n"
        lines = File.readlines(rpz_path)
  
        unless lines.include?(rpz_rule)
          File.open(rpz_path, 'a') do |file|
            file.write(rpz_rule)
          end
          Rails.logger.info "Added #{rpz_rule} to #{rpz_path}"
        end
      else
        Rails.logger.error "No FeedZone found with file_path: #{file_path}"
      end
    end

    def exclude_job(filepath)
      feed_zone = FeedZone.find_by(file_path: filepath)
      if feed_zone
        zone = feed_zone.zone
        rpz_path = zone.zone_path
        rpz_rule = "$INCLUDE #{filepath};\n"
        lines = File.readlines(rpz_path)
        
        if lines.include?(rpz_rule)
          lines.delete(rpz_rule)
          File.open(rpz_path, 'w') do |file|
            file.write(lines.join)
          end
        else
          Rails.logger.error "No #{rpz_rule} found in #{rpz_path}"
        end
      else
        Rails.logger.error "No FeedZone found with file_path: #{filepath}"
      end
    end
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
end
