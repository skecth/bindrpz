require "httparty"
require "nokogiri"
require "uri"
class DomainsController < ApplicationController
  before_action :set_domain, only: %i[ show edit update destroy ]
  include Pagy::Backend
  # GET /domains or /domains.json
  def index
    @feeds = Feed.all
    @domains = Domain.all.order(id: :asc) #make sure the list start from smaller id
    # @domains.each do |domain|
    #   @c =domain.list_domain
    # end

    @sources = @domains.pluck(:source).uniq
    @categories = @domains.pluck(:category).uniq
    if params[:category].present?
      @domains = Domain.where(category: params[:category])
    end
    if params[:source].present?
      @domains = Domain.where(source: params[:source])
    end

  end
  
  def edit
    @feeds = Feed.all
    @feed = Feed.find(params[:feed_id])
  end

  # GET /domains/1 or /domains/1.json
  def show
    @feeds = Feed.all
    id = Domain.find(params[:id])
    @feed = Feed.find(params[:id])
    #get the list_domain
    list = id.list_domain
    #remove unwanted symbol
    if list.present?
      str = list.gsub(/[\[\]"]/, '') #re  move sqaure bracket
      list_domain = str.split(', ') #split based on ,
      @num = list_domain.count
      @content = list_domain
      @pagy,@content = pagy_array(@content.to_a,items: 100)
    else
      puts "No domain list"
    end
  end
  # GET /domains/new
  def new
    @feeds = Feed.all
    @domain = Domain.new(status: params[:status])
    @feed = Feed.all
    @feed = Feed.find(params[:id])
    @source_id = params[:source_id]
    @source_url = params[:URL]
    @domains = Domain.all
    @category = @domains.pluck(:category) #.pluck to get all in the params
    @status = params[:status]
  end

  def create
    @domain = Domain.new(domain_params)
    link = params[:domain][:URL] # Get the link from the form
    cat = params[:domain][:category]
    respond_to do |format|
      #hv two path => blacklist@bulk, this is for bulk add
      if link.present? 
        @domain.status = 'bulk' #save status as bulk
        response = HTTParty.get(link)
        if response.code == 200
          documents = Nokogiri::HTML(response.body)
          lines = documents.text.split("\n")
          # Initialize an empty array to store the lines
          lines_to_save = []
  
          lines.each do |line|
            next if line.strip.start_with?("#")
            clean_line = line.strip.gsub(/\b0\.0\.0\.0\b/, '').gsub(/\bwww.\b/, '')
            # Add each line to the array
            lines_to_save << clean_line
          end          
          #@domain.list_domain = lines_to_save[1..-2]  # Assuming 'lines' is an attribute in your Domain model
          @domain.category = cat.capitalize()
        else
          flash[:notice] ="Errro"
          redirect_to new_domain_path
          format.json { render json: {}, status: :unprocessable_entity }
        end   
        #if link is not present
      else
        #if the link is not present the status will be saved as blacklist
        @domain.status = 'blacklist'
      end
      if @domain.save
        #DomainUpdateJob.perform_async(link) # Enqueue the job here

        format.html { redirect_to root_path, notice: "Categories were successfully created." }
        format.json { render :index, status: :created }
    # if URL exist, then it will not be saved
    if @domain.URL.present?
      if Domain.exists?(URL: @domain.URL)
        redirect_to new_domain_path, alert: "URL already exist"
        puts "URL already exist"

      else
        # Check if the domain URL is valid or not using uri
        uri = URI.parse(@domain.URL)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https' 
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        if response.code.to_i == 200


  def edit 
    #the original version do not have edit def
    @feed = Feed.find(params[:feed_id])
    @domain = Domain.find(params[:id])
  end
 



  # PATCH/PUT /domains/1 or /domains/1.json
  def update
    @feed = Feed.find(params[:id])
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to feed_url(@feed), notice: "Domain was successfully updated." }
          @domain.list_domain = Net::HTTP.get(URI.parse(@domain.URL)).split("\n").select{|line| line[0] != '#' && line != ''}.reject{|line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/}.join("\n")
          # @domain.list_domain = Net::HTTP.get(uri).gsub(/[\[\]"]/, '').split("\n").reject { |line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/ }
          @domain.list_domain = @domain.list_domain.gsub(/^(\b0\.0\.0\.0\b|127.0.0.1)/, '').gsub(/^www\./, '').gsub(/#.*$/, '')


          @lines = @domain.list_domain.split("\n").map(&:strip)
          # puts "Hey Yo: #{@lines}"
          respond_to do |format|
            if @domain.save
              format.html { redirect_to domain_url(@domain), notice: "Domain was successfully created." }
              format.json { render :show, status: :created, location: @domain }
            else
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @domain.errors, status: :unprocessable_entity }
            end
          end
        else
          puts "URL is not valid"
          redirect_to new_domain_path, notice: "URL is not valid"
        end
      end
    end
  end 


  # PATCH/PUT /domains/1 or /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to domain_url(@domain), notice: "Domain was successfully updated." }

        format.json { render :show, status: :ok, location: @domain }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end
        
  def instant_update
    @domain = Domain.find(params[:id])
    if @domain.URL.present?  
      DomainInstantUpdateJob.perform_async(@domain.id)
    else
      puts "no URL"
    end
  end

  

  # DELETE /domains/1 or /domains/1.json
  def destroy
    @domain.destroy
    @feed = Feed.find(params[:id])
    respond_to do |format|
      format.html { redirect_to feed_url(@feed), notice: "Domain was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domain
      @domain = Domain.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def domain_params
      params.require(:domain).permit(:file, :URL, :list_domain, :source, :category,:action,:feed_id, :status)
    end
end

