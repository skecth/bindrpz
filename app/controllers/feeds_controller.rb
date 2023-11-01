class FeedsController < ApplicationController
  before_action :set_feed, only: %i[ show edit update destroy ]
  include Pagy::Backend

  # GET /feeds or /feeds.json
  def index
    @feeds = Feed.all
   
  end

  # GET /feeds/1 or /feeds/1.json
  def show

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
    @feed.feed_name = "#{@feed.category.name}_#{@feed.source}"
    file_name = @feed.feed_name
    file_path = "#{@feed.feed_path}/#{file_name}.txt"

    # Make an HTTP GET request to the URL and write the content to the file
    url = @feed.url
    if url.present?
      if Feed.exists?(url: url)
        redirect_to new_feed_path
      else
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https' 
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        if response.code.to_i == 200 && url.include?(".txt")
          File.open(file_path, 'w') do |file|
             @list_domain = Net::HTTP.get(URI.parse(url)).split("\n").select{|line| line[0] != '#' && line != '' && line[0] != '!'}.reject{|line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/}.join("\n")
             @list_domain = @list_domain.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '').gsub(/^www\./, '').gsub(/#.*$/, '')
             @list_domain = @list_domain.split("\n").map(&:strip).uniq.join("\n") #remove duplicate   
             
             file.write(@list_domain)
          end
          @feed.feed_path = file_path

          respond_to do |format|
            if @feed.save
              format.html { redirect_to feeds_path, notice: "Feed was successfully created." }
              format.json { render :show, status: :created, location: @feed }
            else
              format.html { redirect_to feeds_path }
              format.json { render json: @feed.errors, status: :unprocessable_entity }
            end
          end
        end
      end
    else
      redirect_to new_feed_path
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
    File.delete(@feed.feed_path)
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
      params.require(:feed).permit(:url, 
                                   :source, 
                                   :blacklist_type, 
                                   :feed_name,
                                   :feed_path,
                                   :category_id)
    end
end
