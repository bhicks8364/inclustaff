class Company::Shifts::BreaksController < ApplicationController
  before_action :authenticate_company_admin!
  before_action :set_shift

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
  end

  private

    def set_shift
      @shift = current_company_admin.company.shifts.find(params[:shift_id])
    end
end
