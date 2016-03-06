class Employee::ShiftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee
  before_action :set_job
  layout 'employee'
  
  def index
    @shifts = @job.shifts
  end

  def show
    @shift = @job.shifts.find(params[:id])
  end

  def clock_in
    authorize @job, :clock_in?

    if @job.off_shift?
      @shift = @job.shifts.create(
        time_in: Time.current,
        week: Date.today.beginning_of_week,
        state: "Clocked In",
        in_ip: current_user.current_sign_in_ip
      )

      # current_user.events.create(action: "clocked_in", eventable: @shift.employee)

      respond_to do |format|
          format.json {
            render json: {
              id: @shift.id,
              clocked_in: @shift.clocked_in?,
              clocked_out: @shift.clocked_out?,
              state: @shift.state,
              time_in: @shift.time_in.strftime("%l:%M%P"),
              time_out: @shift.time_out,
              last_out: @job.last_clock_out,
              in_ip: @shift.in_ip,
              first_name: @job.employee.first_name
            }
          }
      end
    end
  end

  def clock_out
    authorize @job, :clock_out?

    if @job.on_shift? && @job.current_shift.present?
      @shift = @job.current_shift
      @shift.update(
        time_out: Time.current,
        state: "Clocked Out",
        out_ip: current_user.current_sign_in_ip,
        week: Date.today.beginning_of_week
      )

      # current_user.events.create(action: "clocked_out", eventable: @shift.employee)

      respond_to do |format|
          format.json {
            render json: {
              id: @shift.id,
              clocked_in: @shift.clocked_in?,
              clocked_out: @shift.clocked_out?,
              state: @shift.state,
              time_in: @shift.time_in.strftime("%l:%M%P"),
              time_out: @shift.time_out.strftime("%l:%M%P"),
              in_ip: @shift.in_ip,
              first_name: @job.employee.first_name
            }
          }
      end
    end
  end

  private
    def set_employee
      @current_user = current_user if user_signed_in?
      @employee = @current_user.employee
      skip_authorization
    end

    def set_job
      @job = @employee.current_job
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:time_in, :time_out, :employee_id, :job_id)
    end
end
