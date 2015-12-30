class Company::JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :clock_in, :clock_out]
  before_action :authenticate_company_admin!
  # before_action :set_order
  layout "company_layout"
  
  def index
    
      @admin = current_company_admin
      @company = @admin.company
      @jobs = @company.jobs.active.order(title: :asc)
      authorize @jobs

  end
  
  def archived
    @admin = current_company_admin
    @company = @admin.company
    @archived_jobs = @company.jobs.inactive.with_employee
    
    authorize @archived_jobs
  end

  def show
    authorize @job
    @employee = @job.employee
    @company = @job.company
    @order = @job.order
    @current_timesheet = @job.current_timesheet
    
    @current_shift = @job.shifts.clocked_in.last if @job.on_shift?
    @all_timesheets = @job.timesheets
    @timesheets = @job.timesheets
    @last_week_timesheets =  @job.timesheets.last_week
    
  end

  
  def verify_code
    @job = Job.find(params[:id])
    skip_authorization
    @code = params[:code]
    @employee_code = @job.employee.code
    @state = @job.on_shift? ? true : false
    authorized = (@code === @employee_code) ? true : false
    respond_to do |format|
      if @code === @employee_code
         format.json { render json: { id: @job.id, code: @employee_code, authorized: authorized, status: :ok, clocked_in: @state} }
      else
        format.json { render json: @job.errors, code: @employee_code, authorized: authorized, clocked_in: @state}
      end
    end
  end
  
  def clock_in

    authorize @job, :clock_in?
    if @job.off_shift?
      @shift = @job.shifts.create(time_in: Time.current, week: Date.today.beginning_of_week.cweek,
                                  state: "Clocked In",
                                  in_ip: "Company-Clock-In")
     current_company_admin.events.create(action: "clocked_in", eventable: @shift, user_id: @shift.employee.user_id)

    
      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?, 
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out, last_out: @job.last_clock_out,
                    in_ip: @shift.in_ip, first_name: @job.employee.first_name, new_count: @job.agency.jobs.on_shift.count } }

      end
    end
  end
  
  def clock_out

    authorize @job, :clock_out?
    if @job.on_shift? && @job.current_shift.present?
        @shift = @job.current_shift
        @shift.update(time_out: Time.current,
                        state: "Clocked Out", week: Date.today.beginning_of_week.cweek,
                        out_ip: "Company-Clock-Out" )
       
      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?, 
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out.strftime("%l:%M%P"),
                    in_ip: @shift.in_ip, first_name: @job.employee.first_name, new_count: @job.agency.jobs.on_shift.count } }

      end
    end
  end
  
  def clock_out_all
      @all_jobs = current_company_admin.jobs
      @jobs = @all_jobs.on_shift
      @jobs.each {|job| job.clock_out! }
      if !@all_jobs.on_shift.any?
        redirect_to company_jobs_path, notice: "You have just clocked out all working employees"
      else
        redirect_to company_jobs_path, notice: "Unable to clocked out #{@jobs.count} employees"
      end
      skip_authorization
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update

    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to company_job_path(@job), notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def pundit_user
      current_company_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
      authorize @job
    end
    
    def set_order
      # @company = Company.find(params[:company_id])
      # @order = Order.find(params[:order_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:order, :recruiter_id, :title, :active, :description, :start_date, :pay_rate, :end_date, :order_id, :employee_id,
                            employee_attributes: [:id, :first_name, :last_name, :email, :ssn, :_destroy])
    end
    def employee_params
      params.require(:employee).permit(:first_name, :last_name, :email, :ssn, :phone_number)
    end
end
