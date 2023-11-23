class FeedsController < ApplicationController
  require 'net/http'
  require 'uri'
  include Pagy::Backend
  before_action :set_feed, only: %i[ show edit update destroy ]
  before_action :validate_link, only: %i[ create ]

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
    # uppercase the feed name
    @feed.feed_name.upcase!
    system("sudo chmod 777 /etc/bind")
    # create /etc/bind/rpz folder if it does not exist
    Dir.mkdir("/etc/bind/feed") unless File.exist?("/etc/bind/feed")
    @feed.feed_path = "/etc/bind/feed/"


    respond_to do |format|
      if @feed.save
        format.html { redirect_to feeds_path, notice: "Feed was successfully created." }
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
      file = File.new("/etc/bind/feed/#{feed.feed_name}.rpz", "w")
      file.puts "# Last updated: #{Time.now.strftime("%d %b %Y %H:%M:%S")}"
      # Net::HTTP.get_response(URI.parse(feed.link)) do |res|
      #   res.body.lines.each do |line|
      #     next if line.start_with?('#') || line.strip.empty? || line.start_with?('!') || line =~ /^:|^ff|^fe|^255|^127|^#|^$/
      #     line.gsub!(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '')
      #     line.gsub!(/^www\./, '')
      #     line.gsub!(/#.*$/, '')
      #     # write line that are not duplicate

          
      #     file.puts line
      #     # file.puts line
      #   end
      # end
      @blacklist_data = Net::HTTP.get(URI.parse(feed.url)).split("\n").select{|line| line[0] != '#' && line != '' && line[0] != '!'}.reject{|line| line =~ /^:|^ff|^fe|^255|^#|^$/}.join("\n")
      @blacklist_data = @blacklist_data.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '').gsub(/#.*$/, '')
      # if the line has space, then split it 
      @blacklist_data = @blacklist_data.split("\n").map{|line| line.split(' ')}.flatten.join("\n")
      @blacklist_data = @blacklist_data.gsub(/^www\./, '')
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
      params.require(:feed).permit(:url, 
                                   :source, 
                                   :blacklist_type, 
                                   :feed_name,
                                   :feed_path,
                                   :category_id)
    end

    def validate_link
      @feed = Feed.new(feed_params)
      # check if link is valid
      uri = URI.parse(@feed.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https' 
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      if response.code.to_i != 200
        render :new, status: :unprocessable_entity, notice: "Feed url is invalid."
        puts "Feed url is invalid."
        return
      else
        @data = []
        host_pattern = Regexp.new(/^0\.0\.0\.0\s+([^\s#]+) | ^127\.0\.0\.1\s+([^\s#]+)/x) # regex for host file
        domain_pattern = Regexp.new(/^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/) # regex for domain
        ip_pattern = Regexp.new(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/) # regex for ip
        dnsmasq_pattern = Regexp.new(/server=\/(.*?)\//) # regex for dnsmasq

        Net::HTTP.get_response(URI.parse(@feed.url)) do |res|
          # check 100 lines only for performance
          res.body.lines.first(100).each do |line|
            next if line.start_with?('#') || line.strip.empty? || line.start_with?('!') || line =~ /^:|^ff|^fe|^255|^$/ || line.include?('localhost')
            case @feed.blacklist_type
            when "Host"
              # @data. << line.split('#')[0].strip if line.match(host_pattern) && !line.nil?
              @data << line.split('#')[0].strip if line.match(host_pattern) && !line.nil?
            when "DNSMASQ"
              @data << line if line.match(dnsmasq_pattern) && !line.nil?
            when "IP"
              @data << line if line.match(ip_pattern) && !line.nil? && !line.match(/[a-zA-Z]/)
            when "Domain"
              puts "Hey Yo :#{line}"
              @data << line if line.match(domain_pattern) && !line.nil?
            end      
          end
        end
        puts "Hey Yo :#{@data}"
        # if @data does not match any pattern, then it is not a valid blacklist
        if @data.empty?
          render :new, status: :unprocessable_entity, notice: "Feed url is invalid."
          puts "Feed url is invalid."
          return
        end
      end
    end

   
end
