class FeedsController < ApplicationController
  before_action :set_feed, only: %i[ show edit update destroy ]
  include Pagy::Backend

  # GET /feeds or /feeds.json
  def index
    @feeds = Feed.all
  end

  # GET /feeds/1 or /feeds/1.json
  def show

    @feed = Feed.find(params[:id])
    @name = "#{@feed.host}.#{@feed.domain}" #pass the variable to view
    @feeds =Feed.all    
    domain = Domain.all
    @feeds = Feed.all
    @feed = Feed.find(params[:id])
    @domains = @feed.domains
    # limit the number of domains to 10 per page using Pagy
    # @pagy, @domains = pagy(@feed.domains, items: 50)
    @urls = @feed.domains.pluck(:URL).uniq

    # count the number of list_domain in each feed
    @feed.domains.each do |domain|
      @c = domain.list_domain
    end
    #remove unwanted symbol
    if @c.present?
      list_domain = @c.split("\n")
      @num = list_domain.count
      @content = list_domain
      @pagy,@content = pagy_array(@content.to_a,items: 100)
    else
      puts "No domain list"
    end
  end


  # GET /feeds/new
  def new
    @feed = Feed.new
    @feeds = Feed.all
  end

  def admin
    @feeds = Feed.all
    @category = Domain.pluck(:category).uniq
    @cat_count = @category.count
    puts @cat_count
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
        format.html { redirect_to feed_url(@feed), notice: "Feed was successfully created." }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
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
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: "Feed was successfully destroyed." }
      format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feed_params
      params.require(:feed).permit(:host, :domain)
    end
end
