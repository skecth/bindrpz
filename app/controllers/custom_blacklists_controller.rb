require 'csv'
class CustomBlacklistsController < ApplicationController
  before_action :set_custom_blacklist, only: %i[ show edit update destroy ]


  # GET /custom_blacklists or /custom_blacklists.json
  def index
    @custom_blacklist = CustomBlacklist.new
    @zone = Zone.find(params[:zone_id])
    @custom_blacklists = @zone.custom_blacklists
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
    zone_id = params[:custom_blacklist][:zone_id]
    @custom_blacklist = CustomBlacklist.new(custom_blacklist_params)

    begin
      if @custom_blacklist.file.present? && @custom_blacklist.file.file.extension.downcase.in?(%w(csv))
          # read the contents of the file
          csv = CSV.read(@custom_blacklist.file.path, headers: false)
          # loop through each line in the file
          csv.each do |row|
            Rails.logger.info "Row: #{row}"
            # skip if domain is already in database
            if CustomBlacklist.where(domain: row[0]).present?
              next
              puts "Domain already exists"
            else
            # create a new custom blacklist for each line in the file
              @custom_blacklist = CustomBlacklist.create(blacklist_type: @custom_blacklist.blacklist_type, action: @custom_blacklist.action, destination: @custom_blacklist.destination, domain: row[0], kind: @custom_blacklist.kind, zone_id: @custom_blacklist.zone_id, category_id: @custom_blacklist.category_id, file: @custom_blacklist.file)
            end
            puts @custom_blacklist.errors.full_messages
          end
      end
    rescue CSV::MalformedCSVError => e
      # Handle the MalformedCSVError here
      @custom_blacklist.errors.add(:file, "Invalid file. Controller")
    end
    

    respond_to do |format|
      if @custom_blacklist.save
        format.html { redirect_to zone_custom_blacklists_path(@custom_blacklist.zone_id), notice: "Custom blacklist was successfully created." }
        format.json { render :show, status: :created, location: @custom_blacklist }
        GenerateBlacklistJob.perform_async
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @custom_blacklist.errors, status: :unprocessable_entity }
        # pass the zone id to the partial
        @zone = Zone.find(params[:custom_blacklist][:zone_id])
        format.turbo_stream { render partial: "custom_blacklists/form_update", status: :unprocessable_entity }
      end
    end
  end

  def delete_all
    zone = Zone.find(params[:id])
    if params[:custom_blacklist_ids].present?

      puts "custom blacklist id exist" 
      CustomBlacklist.destroy(params[:custom_blacklist_ids])
      respond_to do |format|
        format.html { redirect_to zone_custom_blacklists_path(zone.id), notice: "Custom blacklists has been delete " }
        format.json { head :no_content }
      end
    else
      puts "not exist"
    end
  end

  # PATCH/PUT /custom_blacklists/1 or /custom_blacklists/1.json
  def update
    zone_id = params[:custom_blacklist][:zone_id]
    respond_to do |format|
      if @custom_blacklist.update(custom_blacklist_params) && update_files
        format.html { redirect_to zone_custom_blacklists_path(@custom_blacklist.zone_id), notice: "Custom blacklist was successfully updated." }
        format.json { render :show, status: :ok, location: @custom_blacklist }
        GenerateBlacklistJob.perform_async
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @custom_blacklist.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "custom_blacklists/form_update", status: :unprocessable_entity }
      end
    end
   
  end

  # DELETE /custom_blacklists/1 or /custom_blacklists/1.json
  def destroy
    @custom_blacklist = CustomBlacklist.find(params[:id])
    #remove blacklist from the zone file
    RemoveBlacklistJob.perform_async(@custom_blacklist.id)
    respond_to do |format|
      format.html { redirect_to zone_custom_blacklists_path(@custom_blacklist.zone_id), notice: "Custom blacklist was successfully destroyed." }
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

    def update_files
      @custom_blacklist.files&.purge
    end
end
