class RpzdataController < ApplicationController


  def index
    @rpzdata = Rpzdata.all
  end

  def show
  end

  def create
    @rpzdata = Rpzdata.new(rpzdata_params)

    respond_to do |format|
      if @rpzdata.save
        format.html { redirect_to show_url(@rpzdata), notice: "Darjah was successfully created." }
        format.json { render :show, status: :created, location: @rpzdata }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rpzdata.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_rpzdata
    @rpzdata = Rpzdata.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def rpzdata_params
    params.require(:rpzdata).permit(:domain, :category, :action)
  end
end
