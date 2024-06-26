class CategoriesController < ApplicationController
  before_action :authenticate_admin!, except: %i[ index show]
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories or /categories.json
  def index
    @categories = Category.all
    @count = @categories.count
  end

  # GET /categories/1 or /categories/1.json
  def show
    @cat=Category.all
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    @category = Category.new(category_params)
    @category.name.upcase!

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_path, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
        format.turbo_stream { render partial: "categories/form_update", status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to categories_path, notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    respond_to do |format|
      if @category.destroy 
        format.html { redirect_to categories_url, notice: "Category was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to categories_url, notice: "Category can't be destroyed. There are some zones used the feed in this category." }
        format.json { head :no_content }
      end
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.require(:category).permit(:name)
    end

    def authenticate_admin!
      unless current_user.admin?
        redirect_to categories_path, alert: "You don't have access to this page"
      end
    end
    
end
