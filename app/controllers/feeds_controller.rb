class FeedsController < ApplicationController
  require 'net/http'
  require 'uri'
  include Pagy::Backend
  before_action :authenticate_admin!, except: %i[ index show]
  before_action :set_feed, only: %i[ show edit update destroy ]

  # GET /feeds or /feeds.json
  def index
    @feeds = Feed.all
   
  end

  # GET /feeds/1 or /feeds/1.json
  def show
    @feeds =Feed.all    
    @feed = Feed.find(params[:id])
    @pagy, @blacklist_data = pagy_array(File.read(@feed.feed_path).split("\n").reject{|line| line.start_with?('#')}, items: 20)
  end


  # GET /feeds/new
  def new
    @feed = Feed.new
    @feeds = Feed.all
  end

  def admin
    @categories = Category.all
    @category_count = @categories.count
  end

  # GET /feeds/1/edit
  def edit
    @feeds = Feed.all
  end

  # POST /feeds or /feeds.json
 

  def create
    @feed = Feed.new(feed_params)
    
    respond_to do |format|
      if @feed.save
        format.html { redirect_to feeds_path, notice: "Feed was successfully created." }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "categories/form_update", status: :unprocessable_entity }
      end
    end
  end

  def search
    @feed = Feed.find(params[:id])
    @search_feed = params[:search_feed]
    if @search_feed.present?
      @data = File.read(@feed.feed_path).split("\n").reject { |line| line.start_with?('#') }
      @blacklist_data = @data.select { |line| line.include?(@search_feed) }
      Rails.logger.debug(@blacklist_data)
    else
      @blacklist_data = File.read(@feed.feed_path).split("\n").reject { |line| line.start_with?('#') }
    end
    render turbo_stream: turbo_stream.replace('blacklist_data', partial: 'result',locals: {blacklist_data: @blacklist_data})
  end

  # PATCH/PUT /feeds/1 or /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to feed_url(@feed), notice: "Feed was successfully updated." }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1 or /feeds/1.json
  def destroy
    @feed = Feed.find(params[:id])
    respond_to do |format|
      if @feed.destroy
        format.html { redirect_to feeds_url, notice: "Feed was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to feeds_url, notice: "Feed can't be destroyed. There are some zones used the feed." }
        format.json { head :no_content }
      end
    end
  end

  def bulk_create
    if Sidekiq::Workers.new.size > 0 
      redirect_to feeds_url, notice: "Automatic update is running. Please wait for a while until it finishes."
    else
      DomainUpdateJob.perform_now
       redirect_to feeds_url, notice: "Feeds have been successfuly updated."
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feed_params
      params.require(:feed).permit(:url, :source, :blacklist_type, :category_id, :number_of_domain)
    end

    def authenticate_admin!
      unless current_user.admin?
        redirect_to feeds_path, notice: "You are not authorized to access this page."
      end
    end
   
end
