class FeedsController < ApplicationController
  require 'net/http'
  require 'uri'
  include Pagy::Backend
  before_action :authenticate_admin!, except: %i[ index]
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

    feed_name= @feed.feed_name = "#{@feed.category.name}_#{@feed.source}"
    # @feed.feed_name.upcase!

    system("sudo chmod 777 /etc/bind")
    # create /etc/bind/rpz folder if it does not exist
    Dir.mkdir("/etc/bind/feed") unless File.exist?("/etc/bind/feed")
    @feed.feed_path = "/etc/bind/feed/#{feed_name.upcase!}.txt"
  

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
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: "Feed was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def bulk_create
    if Sidekiq::Workers.new.size > 0 
      redirect_to feeds_url, notice: "Automatic update is running. Please wait for a while until it finishes."
    else
      DomainUpdateJob.perform_now
       redirect_to feeds_url, notice: "Update is running. Please wait for a while."
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feed_params
      params.require(:feed).permit(:url, :source, :blacklist_type, :feed_name, :feed_path, :category_id, :number_of_domain)
    end

    def authenticate_admin!
      unless current_user.admin?
        redirect_to feeds_path, notice: "You are not authorized to access this page."
      end
    end
   
end
