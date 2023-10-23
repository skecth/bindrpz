class FeedsController < ApplicationController
  before_action :set_feed, only: %i[ show edit update destroy ]

  # GET /feeds or /feeds.json
  def index
      @feeds = Feed.all
      @feed = Feed.where(id: params[:id])
  end

  # GET /feeds/1 or /feeds/1.json
  def show
     @feed = Feed.find(params[:id])
     @name = "#{@feed.host}.#{@feed.domain}"
    # @feeds = Feed.where(id: params[:id])
    @feeds =Feed.all    
    domain = Domain.all
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  def admin
    @feeds = Feed.all
    @category = Domain.pluck(:category).uniq
    @cat_count = @category.count
    puts @cat_count
  end

  # GET /feeds/1/edit
  def edit
  end
  
  def sidebar
    @feed = Feed.all
    @domain = Domain.all
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

  def create_feed
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
