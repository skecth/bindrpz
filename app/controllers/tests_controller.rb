class TestsController < ApplicationController
  before_action :set_test, only: %i[ show edit update destroy ]

  # GET /tests or /tests.json
  def index
    @tests = Test.all
  end

  # GET /tests/1 or /tests/1.json
  def show
  end

  # GET /tests/new
  def new
    @test = Test.new
  end

  # GET /tests/1/edit
  def edit
  end

  # POST /tests or /tests.json
  def create
    @rpzdata = Rpzdata.new(darjah_params)

    respond_to do |format|
      if @darjah.save
        format.html { redirect_to darjah_url(@darjah), notice: "Darjah was successfully created." }
        format.json { render :show, status: :created, location: @darjah }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @darjah.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tests/1 or /tests/1.json
  def update
    respond_to do |format|
      if @test.update(test_params)
        format.html { redirect_to test_url(@test), notice: "Test was successfully updated." }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tests/1 or /tests/1.json
  def destroy
    @test.destroy

    respond_to do |format|
      format.html { redirect_to tests_url, notice: "Test was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rpzdata
      @test = Test.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def _params
      params.require(:test).permit(:link, :file)
    end
end
