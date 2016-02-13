class Company::Shifts::BreaksController < ApplicationController
  before_action :authenticate_company_admin!
  before_action :set_shift
  layout "company_layout"
  
  def index
    skip_authorization
  end
  def edit
    @shift_break = @shift.breaks.find(params[:id])
    skip_authorization
  end
  def update
    @shift_break = @shift.breaks.find(params[:id])
    skip_authorization
    respond_to do |format|
      if @shift_break.update(shift_break_params)
        format.html { redirect_to company_shift_path(@shift), notice: 'Shift was successfully updated.' }
        format.json { render :show, status: :ok, location: @shift }
      else
        format.html { render :edit }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
    
  end
  def start
    skip_authorization

    @current_break = @shift.current_break
    if @current_break.nil?
      @current_break = @shift.breaks.create!(time_in: Time.current)
    end

    @shift.update(state: "On Break")
  end

  def stop
    skip_authorization

    @current_break = @shift.current_break
    @current_break.update(time_out: Time.current)
    @shift.update(state: "Clocked In")
    @shift_break = @shift.breaks.last
  end
  
  def destroy
    @shift = Shift.find(params[:shift_id])
    @shift_break = Break.find(params[:id])
    @shift_break.destroy
    skip_authorization
    respond_to do |format|
      format.html { redirect_to company_shift_breaks_path(@shift), notice: 'Break was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_shift
      @shift = current_company_admin.company.shifts.find(params[:shift_id])
      
    end
    def shift_break_params
      params.require(:break).permit(:time_in, :time_out, :shift_id, :paid)
    end
end
