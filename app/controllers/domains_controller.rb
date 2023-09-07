class DomainsController < ApplicationController
  before_action :set_domain, only: %i[ show edit update destroy ]

  # GET /domains or /domains.json
  def index
    @domains = Domain.all
  end

  # GET /domains/1 or /domains/1.json
  def show
    id = Domain.find(params[:id])
    #split into the array content
    @content = id.content.split("\n")
  end

  # GET /domains/new
  def new
    @domain = Domain.new
  end

  def search
    @id = Domain.find(params[:id])
    keyword = params[:search]
    puts "keyword: #{keyword}"
  
    # Split the content into a list of items using "\r\n" as the delimiter
    content_items = @id.content.split("\r\n")
    puts "content_item #{content_items}"
    # Initialize an array to store matching items
    @results = []
  
    # Iterate through each item and check if the keyword is present
    content_items.each do |item|
      puts "item: #{item}"
      if item.include?(keyword)
        @results << item
      end
    end
  
    puts "Matching items: #{@results}"
  end
  
  
  
  #testing
  def write
    file_path = params[:link]
    # content = "nama saya azimmabrsdfsdffssfso"
    
    begin
      File.open(file_path, 'w') do |file|
        file.write(content)
      end
      
      puts "File was successfully written."
      redirect_to root_path, notice: "File was successfully written."
    rescue => e
      puts "Failed to write the file: #{e.message}"
      flash[:error] = "Failed to write the file: #{e.message}"
      redirect_to domains_path
    end
  end
  

  # GET /domains/1/edit
  def edit
    id = Domain.find(params[:id])
    @content = id.content
  end

  # POST /domains or /domains.json
def create
  require "httparty"
  require "nokogiri"
  # Get the input github
  @domain = Domain.new(domain_params)
  link = params[:domain][:link]
  
  respond_to do |format|
    if link.present?
      response = HTTParty.get(link)
      if response.code == 200
        documents = Nokogiri::HTML(response.body)
        lines = documents.text.split("\n")
        
        lines.each do |line|
          next if line.strip.start_with?("#") #remove all the line start with #
          # Create a new category for each line
          domain = Domain.new(domain_params) # Create a new category for each line
          domain.content = line.strip
          if domain.save
            puts "Save"
          else
            flash[:alert] = "Failed to save a category for line: #{line}"
          end
        end

        format.html { redirect_to domains_url, notice: "Categories were successfully created." }
        format.json { render :index, status: :created }
      else
        flash[:alert] = "Failed to fetch data from GitHub. HTTP Status: #{response.code}"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: {}, status: :unprocessable_entity }
      end   
    else
      flash[:alert] = "GitHub or Url link is missing."
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: {}, status: :unprocessable_entity }
    end
  end # Add this 'end' to close the 'respond_to' block
end

  # PATCH/PUT /domains/1 or /domains/1.json
  def update
    id = Domain.find(params[:id])
    domain_list = id.content.split("\n")
    puts "Domain List: #{domain_list}"
    update_text = params[:content]   
    puts "update: #{update_text}"
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
      params.require(:domain).permit(:file, :link, :content, :search, :source_id, :category_id)
    end
end
