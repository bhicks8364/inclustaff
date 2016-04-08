class Admin::Timesheets::AdjustmentsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_timesheet
  layout "admin_layout"
  
    def index
      @adjustments = @timesheet.adjustments
      skip_authorization
    end
    def new
      @adjustment = @timesheet.adjustments.new
      skip_authorization
      respond_to do |format|
        format.js 
        format.html 
      end
    end
    
    def create
        @adjustment = @timesheet.adjustments.new(adjustment_params)
        if @adjustment.vacation?
          @adjustment.bill_rate = 0
          @adjustment.bill_amount = 0
        end
        skip_authorization
        @adjustment.save
      respond_to do |format|
        format.js 
        format.html { redirect_to admin_timesheet_path(@timesheet), notice: "Adjustment was successfully added to #{@timesheet.id}." }
        format.json { head :no_content }
      end
    end
    def destroy
        @adjustment = @timesheet.adjustments.find(params[:id])
        @adjustment.destroy
        skip_authorization
        respond_to do |format|
            # format.js
            format.html { redirect_to admin_timesheet_path(@timesheet), notice: 'Adjustment was successfully destroyed.' }
            format.json { head :no_content }
        end
    
    end
    
    private

    def set_timesheet
      @timesheet = Timesheet.find(params[:timesheet_id])
    end
    def adjustment_params
      params.require(:adjustment).permit(:timesheet_id, :adj_type, :amount, :pay_rate, :bill_rate, :hours, :taxable, :entered_by, :bill_amount)
    end
end
