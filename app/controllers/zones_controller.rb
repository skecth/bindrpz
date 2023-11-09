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
    @feed_zones = @zone.feed_zones
    puts @feed_zones
    @custom_blacklists = CustomBlacklist.all.where(zone_id: @zone.id)
  end

  # GET /zones/new
  def new
    @zone = Zone.new
  end

  # GET /zones/1/edit
  def edit
  end

  # POST /zones or /zones.json
  def create
    @zone = Zone.new(zone_params)

    respond_to do |format|
      if @zone.save
        format.html { redirect_to zones_path, notice: "Zone was successfully created." }
        format.json { render :show, status: :created, location: @zone }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "zones/form_update", status: :unprocessable_entity }

      end
    end
  end

  # PATCH/PUT /zones/1 or /zones/1.json
  def update
    respond_to do |format|
      if @zone.update(zone_params)
        format.html { redirect_to zone_path, notice: "Zone was successfully updated." }
        format.json { render :show, status: :ok, location: @zone }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zones/1 or /zones/1.json
  def destroy
    @zone = Zone.find(params[:id])
    # file = @zone.feed_zone.file_path
    @zone.destroy
    
    respond_to do |format|
      format.html { redirect_to rpz_zone_path(@zone), notice: "Zone was successfully destroyed." }
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
                                    :description
      )          
    end
end
