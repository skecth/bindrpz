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
    # # @name = "#{@feed.host}.#{@feed.domain}" #pass the variable to view
    @feeds =Feed.all    
    @feed = Feed.find(params[:id])
    # read the file 50 lines at a time
    @pagy, @blacklist_data = pagy_array(File.read(@feed.feed_path).split("\n"), items_extra: true)
    
    # @blacklist_data = File.read(@feed.feed_path).split("\n")
    


    # domain = Domain.all
    # @feeds = Feed.all
    # @feed = Feed.find(params[:id])
    # @domains = @feed.domains
    # # limit the number of domains to 10 per page using Pagy
    # # @pagy, @domains = pagy(@feed.domains, items: 50)
    # @urls = @feed.domains.pluck(:URL).uniq

    # # count the number of list_domain in each feed
    # @feed.domains.each do |domain|
    #   @c = domain.list_domain
    # end
    # #remove unwanted symbol
    # if @c.present?
    #   list_domain = @c.split("\n")
    #   @num = list_domain.count
    #   @content = list_domain
    #   @pagy,@content = pagy_array(@content.to_a,items: 100)
    # else
    #   puts "No domain list"
    # end
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
    # create files in /etc/bind/rpz folder for each feed
    system("sudo chmod 777 /etc/bind")
    @feeds = Feed.all
    # create /etc/bind/rpz folder if it does not exist
    Dir.mkdir("/etc/bind/feed") unless File.exist?("/etc/bind/feed")
    
    @feeds.each do |feed|
      # give permission to create file
      system("sudo chmod 777 /etc/bind/feed")
      # create file
      file = File.new("/etc/bind/feed/#{feed.feed_name}.txt", "w")
      file.puts "# Last updated: #{Time.now.strftime("%d %b %Y %H:%M:%S")}"
      @blacklist_data = Net::HTTP.get(URI.parse(feed.url)).split("\n").select{|line| line[0] != '#' && line != '' && line[0] != '!'}.reject{|line| line =~ /^:|^ff|^fe|^255|^#|^$/}.join("\n")
      @blacklist_data = @blacklist_data.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '').gsub(/#.*$/, '')
      # if the line has space, then split it 
      @blacklist_data = @blacklist_data.split("\n").map{|line| line.split(' ')}.flatten.join("\n")
      # remove . at the end of the line
      @blacklist_data = @blacklist_data.gsub(/\.$/, '')
      # @blacklist_data = @blacklist_data.gsub(/^www\./, '')
      @blacklist_data = @blacklist_data.split("\n").map(&:strip).uniq.join("\n")  #remove duplicate  
      file.puts @blacklist_data
      # close file
      file.close
    end
    # reload bind9
    # system("sudo systemctl reload bind9")
    # redirect to feeds page
    redirect_to feeds_url, notice: "Feeds were successfully created."
    puts "Feeds were successfully created."
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
