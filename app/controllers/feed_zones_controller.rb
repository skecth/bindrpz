class FeedZonesController < ApplicationController
  before_action :set_feed_zone, only: %i[ show edit update destroy ]

  # GET /feed_zones or /feed_zones.json
  def index
    @feed_zones = FeedZone.all
    @zones = Zone.all
    @zone = Zone.find(params[:id])
  end

  # GET /feed_zones/1 or /feed_zones/1.json
  def show
    @feed_zones = FeedZone.all
    @zones = Zone.all
    @id = FeedZone.find(params[:id])
  end

  # GET /feed_zones/new
  def new
    @feed_zone = FeedZone.new
    @zone = Zone.find(params[:id])
    @feeds = Feed.all

  end

  def feed_upload_check
    @zones = Zone.all
    @zone = Zone.find(params[:id])
    @feedZone = FeedZone.all
    file = params[:file_path]
    if params[:feed_ids].present?
      params[:feed_ids].each do |feed_id|
        puts "feed ID: #{feed_id}"  
        next unless Feed.exists?(id: feed_id)
        feed_zone = FeedZone.find_by(zone_id: @zone.id, feed_id: feed_id)
        if feed_zone
          feed_zone.update(zone_id: @zone.id, feed_id: feed_id, category_id: 1, action: "DROP", destination: "google.com", file_path: file)
        else
          @feedZone = FeedZone.create(zone_id: @zone.id, feed_id: feed_id, category_id: 1, action: "DROP", destination: "google.com", file_path: file)
        end
      end
      redirect_to zone_path(@zone)
    end
  end

 
  # GET /feed_zones/1/edit
  def edit
    @zone = FeedZone.find(params[:id])
  end

  def pull
    @feedZone = FeedZone.all
    @feedZone.each do |feedzone|
     puts "The url #{feedzone.feed.url}"  
    end
  end

  # POST /feed_zones or /feed_zones.json
  def create
    @zone = Zone.find(params[:zone_id])
    params[feed_ids].each do |feed_id|
    end
    @feed_zone = FeedZone.new(feed_zone_params)
    zone_file_path = @feed_zone.file_path
    #create new file
    #id = params[:feed_zone][:zone_id]
    feed_id = params[:feed_zone][:feed_id]
    fID = Feed.find(feed_id)
    fPath = fID.feed_path
    zone = Zone.find(params[:feed_zone][:zone_id])
    name = zone.name
    path = zone.zone_path
    file = "#{path}/#{name}.txt"

    File.open(file, 'w') do |file|
      file.write("@include #{fPath}")
    end
    @feed_zone.file_path = file
    respond_to do |format|
      if @feed_zone.save
        @zone = @feed_zone.zone  # Set @zone to the associated zone of @feed_zone
        format.html { redirect_to zone_url(@zone), notice: "Feed zone was successfully created." }
        format.json { render :show, status: :created, location: @feed_zone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feed_zone.errors, status: :unprocessable_entity }
      end
    end
  end
 
 
  # PATCH/PUT /feed_zones/1 or /feed_zones/1.json
  def update
    respond_to do |format|
      if @feed_zone.update(feed_zone_params)
        format.html { redirect_to feed_zone_url(@feed_zone), notice: "Feed zone was successfully updated." }
        format.json { render :show, status: :ok, location: @feed_zone }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feed_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feed_zones/1 or /feed_zones/1.json
  def destroy
    @id = FeedZone.find(params[:id])
    File.delete(@feed_zone.file_path)
    @feed_zone.destroy

    respond_to do |format|
      format.html { redirect_to rpz_zone_path(@id), notice: "Feed zone was successfully destroyed." }
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
      params.require(:feed_zone).permit(:action, 
                                        :destination,
                                        :zone_id,
                                        :file_path,
                                        :category_id,
                                        :feed_id
                                        )
    end
end
