class CustomBlacklistsController < ApplicationController
  before_action :set_custom_blacklist, only: %i[ show edit update destroy ]

  # GET /custom_blacklists or /custom_blacklists.json
  def index
    @custom_blacklists = CustomBlacklist.all
  end

  # GET /custom_blacklists/1 or /custom_blacklists/1.json
  def show
  end

  # GET /custom_blacklists/new
  def new
    @custom_blacklist = CustomBlacklist.new
    @zone = Zone.find(params[:zone_id])
  end

  def new_bulk
    @custom_blacklist = CustomBlacklist.new
    @zone = Zone.find(params[:zone_id])
  end

  # GET /custom_blacklists/1/edit
  def edit
  end

  # POST /custom_blacklists or /custom_blacklists.json
  def create
    @custom_blacklist = CustomBlacklist.new(custom_blacklist_params)

    respond_to do |format|
      if @custom_blacklist.save
        format.html { redirect_to zone_url(@custom_blacklist.zone_id), notice: "Custom blacklist was successfully created." }
        format.json { render :show, status: :created, location: @custom_blacklist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @custom_blacklist.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "custom_blacklists/form_update", status: :unprocessable_entity }

      end
    end
  end

  # PATCH/PUT /custom_blacklists/1 or /custom_blacklists/1.json
  def update
    respond_to do |format|
      if @custom_blacklist.update(custom_blacklist_params)
        format.html { redirect_to custom_blacklist_url(@custom_blacklist), notice: "Custom blacklist was successfully updated." }
        format.json { render :show, status: :ok, location: @custom_blacklist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @custom_blacklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /custom_blacklists/1 or /custom_blacklists/1.json
  def destroy
    @custom_blacklist.destroy

    respond_to do |format|
      format.html { redirect_to custom_blacklists_url, notice: "Custom blacklist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_custom_blacklist
      @custom_blacklist = CustomBlacklist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def custom_blacklist_params
      params.require(:custom_blacklist).permit(:file, :blacklist_type, :action, :destination, :domain, :kind, :zone_id, :category_id)
    end
end