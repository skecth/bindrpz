
class RulesController < ApplicationController
  before_action :set_rule, only: %i[ show edit update destroy ]

  # GET /rules or /rules.json
  def index
    @rules = Rule.all
  end

  # GET /rules/1 or /rules/1.json
  def show
  end

  # GET /rules/new
  def new
    @rule = Rule.new
  end

  # GET /rules/1/edit
  def edit
  end

  # POST /rules or /rules.json
  def create
    require 'nokogiri'
    require 'httparty'
  
    url = params[:rule][:path]
    puts "URL: #{url}"
    @rule = Rule.new(rule_params)
  
    respond_to do |format|
      if @rule.save
        # Website scraping - start
        begin
          # Make an HTTP GET request and parse the response with Nokogiri
          response = HTTParty.get(url)
  
          parsed_html = Nokogiri::HTML(response.body)
          text = 0
          while text < parsed_html.length
            
          # Extract data from the HTML using a regular expression
          regex = /\A\w+:\/\/\w+\.\w+\.\w+\//
          data = parsed_html.to_s.scan(regex)
          if data.present?
             puts "yay"
          else
            puts "nay"
          end

          # Process and use the extracted data as needed
          data.each do |item|
            # You can save or process the data here, e.g., create a related record
            @rule.scraped_data.create(content: item)
            puts "Item: #{item}"
          end
          
          # Redirect to a specific path or render a view as needed
          format.html { redirect_to rule_url(@rule), notice: "Rule was successfully created and data was scraped." }
          format.json { render :show, status: :created, location: @rule }
        rescue => e
          # Handle any errors that occur during scraping
          flash[:error] = "Failed to scrape data: #{e.message}"
        end
  
        format.html { redirect_to rule_url(@rule), notice: "Rule was successfully created." }
        format.json { render :show, status: :created, location: @rule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end
  

  # PATCH/PUT /rules/1 or /rules/1.json
  def update
    respond_to do |format|
      if @rule.update(rule_params)
        format.html { redirect_to rule_url(@rule), notice: "Rule was successfully updated." }
        format.json { render :show, status: :ok, location: @rule }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1 or /rules/1.json
  def destroy
    @rule.destroy

    respond_to do |format|
      format.html { redirect_to rules_url, notice: "Rule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      @rule = Rule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rule_params
      params.require(:rule).permit(:path, :content, :text_rule)
    end
end
