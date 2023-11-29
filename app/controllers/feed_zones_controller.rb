#feed_zone controlle
class FeedZonesController < ApplicationController
  before_action :set_feed_zone, only: %i[ show edit update destroy]

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
    @categories = Category.all
    @zone = Zone.find(params[:id])
    @categoryFeed = @categories.select { |cat| cat.feeds.any?}
    @feeds = Feed.all
  end


  def feed_upload_check
    @zones = Zone.all
    @categories = Category.all
    @categoryFeed = @categories.select { |cat| cat.feeds.any? }
    @zone = Zone.find(params[:id]) 
    @feedZone = FeedZone.all

    if params[:feed_ids].present?
      puts "Feed ids present"
      params[:feed_ids].each do |feed_id|
        feedID = Feed.find(feed_id)
        categoryID = feedID.category_id
        category = Category.find(feedID.category_id)

        file_zone = "/etc/bind/#{@zone.name}/#{category.name}.rpzfeed"
        # Get the selected action and destination for this feed
        selected_action = params["feed_#{feed_id}_selected_action"]
        feedDestination = params["feed_#{feed_id}_destination"]

        if feed_zone.nil?
          @feedZone = FeedZone.create(zone_id: @zone.id, feed_id: feed_id, selected_action: selected_action, destination: feedDestination, file_path: file_zone, category_id: categoryID)
        else
          flash[:alert] ="Feed already exist"
        end
      end
      GenerateRpzJob.perform_async
      redirect_to zone_path(@zone)
    end
  end

  
 
  # GET /feed_zones/1/edit
  def edit
   @feeds = Feed.all
   @feed_zone = FeedZone.find(params[:id])
   @feed_id = @feed_zone.feed_id
   @category =@feed_zone.category_id

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
    cat_id = params[:category_ids]
    categories = Category.where(id: cat_id) # Retrieve categories based on IDs
    all_saved = true
    categories.each do |cat|
      cat.feeds.each do |feed|
        feed_id = feed.id
        feed_zone_path = feed.feed_path
        selected_action = params[:feed_zone][:selected_action]
        feedDestination = params[:feed_zone][:destination]
        puts selected_action
        puts feedDestination
        # @feed_zone = FeedZone.create(zone_id: zone.id, feed_id: feed_id, selected_action: selected_action, destination: feedDestination, file_path: feed_zone_path) 

      #   if !@feed_zone.save
      #     all_saved = false
      #   end
      end
    end
  end

 
  def include
    filepath = params[:path]
    id = params[:id]
    @feed_zone = FeedZone.find_by(id: id)
    @feed_zone.update(enable_disable_status: true) 
    IncludeJob.perform_async(filepath)
    redirect_to zone_path(filepath)
  end

  def exclude
    filepath = params[:path]
    id = params[:id]
    @feed_zone = FeedZone.find_by(id: id)
    @feed_zone.update(enable_disable_status: false) 
    ExcludeJob.perform_async(filepath)
    redirect_to zone_path(filepath)
    #redirect_to zone_path(filepath), notice: "File was successfully excluded."
  end
 
  # PATCH/PUT /feed_zones/1 or /feed_zones/1.json
  def update

    respond_to do |format|
      if @feed_zone.update(feed_zone_params)
        format.html { redirect_to zone_path(@feed_zone.zone_id), notice: "Feed zone was successfully updated." }
        format.json { render :show, status: :ok, location: @feed_zone }
        GenerateRpzJob.perform_async
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
    #delete file_path
    file_path = @id.file_path
    if File.exist?(file_path)
      system("sudo rm #{file_path}")
    end
    
    @id.destroy
    respond_to do |format|
      format.html { redirect_to zone_url(@id.zone_id), notice: "Feed zone was successfully destroyed." }
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
      params.require(:feed_zone).permit(:selected_action, :destination, :zone_id, :file_path, :category_id, :feed_id)
    end
end
