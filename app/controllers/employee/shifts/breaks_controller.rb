class Employee::Shifts::BreaksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee
  before_action :set_job
  before_action :set_shift

  def start
    authorize @job, :clock_in?

    @current_break = @shift.current_break
    if @current_break.nil?
      @current_break = @shift.breaks.create!(time_in: Time.current)
    end

    @shift.update(state: "On Break")
  end

  def stop
    authorize @job, :clock_in?

    @current_break = @shift.current_break
    @current_break.update(time_out: Time.current)
    @shift.update(state: "Clocked In")
  end

  private

    def set_employee
      @employee = current_user.employee
    end

    def set_job
      @job = @employee.current_job
    end

    def set_shift
      @shift = @job.current_shift
    end
end
