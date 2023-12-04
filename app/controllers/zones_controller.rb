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
        ConfigZoneJob.perform_async

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "zones/form_update", status: :unprocessable_entity }

      end
    end
  end


  # PATCH/PUT /zones/1 or /zones/1.json
  def update
    feed_zones_attributes = params[:zone][:feed_zones_attributes] # Ensure the correct nesting
    puts "feed_zones_attributes: #{feed_zones_attributes}"
    file_path = feed_zones_attributes.values.first['file_path']     
    respond_to do |format|
      if @zone.update(zone_params)
        format.html { redirect_to zone_path, notice: "Zone was successfully updated." }
        format.json { render :show, status: :ok, location: @zone }
        GenerateRpzJob.perform_async
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "zones/nested_feed_zone_create", status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zones/1 or /zones/1.json
  def destroy
    #RemoveConfigZoneJob.perform_async(@zone.id)
    @zone = Zone.find(params[:id])
    #remove zone from config
    RemoveConfigZoneJob.perform_async(@zone.id)
    #@zone.destroy
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
