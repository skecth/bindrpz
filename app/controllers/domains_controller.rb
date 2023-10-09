require "httparty"
require "nokogiri"
class DomainsController < ApplicationController
  before_action :set_domain, only: %i[ show edit update destroy ]
  include Pagy::Backend
  # GET /domains or /domains.json
  def index
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


  # GET /domains/1 or /domains/1.json
  def show
    id = Domain.find(params[:id])
    #get the list_domain
    list = id.list_domain
    #remove unwanted symbol
    if list.present?
      str = list.gsub(/[\[\]"]/, '') #remove sqaure bracket
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
    @domain = Domain.new
    @source_id = params[:source_id]
    @source_url = params[:URL]
    @domains = Domain.all
    @category = @domains.pluck(:category) #.pluck to get all in the params
  end
 

  def create
    link = params[:domain][:URL] # Get the link from the form
    cat = params[:domain][:category]
    respond_to do |format|
      if link.present?
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

          # Create a new Domain record with the array of lines
          @domain = Domain.new(domain_params)
          #@domain.list_domain = lines_to_save[1..-2]  # Assuming 'lines' is an attribute in your Domain model
          @domain.category = cat.capitalize()
  
          if @domain.save
            #DomainUpdateJob.perform_async(link) # Enqueue the job here
  
            format.html { redirect_to domains_url, notice: "Categories were successfully created." }
            format.json { render :index, status: :created }
          else
            flash[:alert] = "Failed to save the domain with lines."
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: {}, status: :unprocessable_entity }
          end
        else
          flash[:notice] ="Errro"
          redirect_to new_domain_path
          format.json { render json: {}, status: :unprocessable_entity }
        end   
      else
        flash[:alert] = "URL link is missing."
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def add_job
    DomainAddJob.perform_async
  end


  # PATCH/PUT /domains/1 or /domains/1.json
  def update
    link = params[:domain][:URL]
    id = Domain.find(params[:id])
      respond_to do |format|
        if link.present?
          response = HTTParty.get(link)
          if response.code == 200
            documents = Nokogiri::HTML(response.body)
            lines = documents.text.split("\n")
            # Initialize an empty array to store the lines
            lines_to_save = []
    
            lines.each do |line|
              next if line.strip.start_with?("#")
              
              # Add each line to the array
              lines_to_save << line.strip
            end
    
            # Create a new Domain record with the array of lines
            id.list_domain = lines_to_save  # Assuming 'lines' is an attribute in your Domain m
            if @domain.update(domain_params)
              
              format.html { redirect_to domain_url(@domain), notice: "Domain was successfully updated." }
              format.json { render :show, status: :ok, location: @domain }
            else
              format.html { render :edit, status: :unprocessable_entity }
              format.json { render json: @domain.errors, status: :unprocessable_entity }
            end
          else
            flash[:alert] = "Failed to fetch data from the URL. HTTP Status: #{response.code}"
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: {}, status: :unprocessable_entity }
          end   
        else
          flash[:alert] = "URL link is missing."
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: {}, status: :unprocessable_entity }
        end
      end
  end
  
  

  # DELETE /domains/1 or /domains/1.json
  def destroy
    @domain.destroy

    respond_to do |format|
      format.html { redirect_to domains_url, notice: "Domain was successfully destroyed." }
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
      params.require(:domain).permit(:file, :URL, :list_domain, :source, :category)
    end
end
