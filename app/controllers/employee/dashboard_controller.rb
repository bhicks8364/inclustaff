class Employee::DashboardController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_employee

  layout 'employee'

  def timeclock
    @company = @employee.company if @employee.present?
    @shifts = @employee.shifts.order(time_in: :desc)
  end

  def home
    @shifts = @employee.shifts
    @job = @employee.current_job
    @company = @job.company if @job.present?
    @jobs = @employee.jobs
    @orders = @current_agency.orders.needs_attention
    gon.shifts = @shifts
    gon.emp_code = @employee.code
    gon.clocked_in = @employee.clocked_in?
    gon.current_shift = @job.current_shift if @job
    gon.current_job = @job
    if @employee.clocked_in?
      @shift = @employee.current_shift
      render "employee/shifts/show"
    end
    
    
  end

  def edit_profile
    @employee = current_user.employee
  end

  def employee_view

    @timesheets = @employee.timesheets

  end
  def jobs
    @orders = @current_agency.orders.needs_attention
  end
  def profile
    @skill = @employee.skills.new
    @work_histories = @employee.work_histories
    @job = @employee.current_job
    @jobs = @employee.jobs
    @shifts = @job.shifts if @job.present?
  end

  private

  def set_employee
    @user = current_user
    @employee = @user.employee
    skip_authorization
  end



end
