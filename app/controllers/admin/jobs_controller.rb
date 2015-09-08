class Admin::JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :clock_in, :clock_out]
  before_action :authenticate_admin!



  def index
    @admin = current_admin
    @company = @admin.company
    @jobs = @company.jobs.order(title: :asc)
    authorize @jobs

  end
  
  def archived
    @admin = current_admin
    @company = @admin.company
    @archived_jobs = @company.jobs.inactive.with_employee
    @active_jobs = @company.active.with_employee
    
    @all_jobs = Job.all
    # authorize @active_jobs
  end





  # GET /jobs/1
  # GET /jobs/1.json
  def show
    authorize @job
    @timesheet = @job.current_timesheet if @job.current_timesheet.present?
    @shift = @job.shifts.last if @job.shifts.any?
    @timesheets = @job.timesheets if @job.timesheets.any?
    @last_week_timesheets =  @job.timesheets.last_week
    
  end

  # GET /jobs/new
  def new
    
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      @job = @order.jobs.new
      authorize @job
    else
      @company = current_admin.company
      @orders = @company.orders

    
      @job = @job = Job.new
      authorize @job

    end


  end

  def clock_in
    authorize @job, :clock_out?
    if @job.off_shift?
      @shift = @job.shifts.create(time_in: Time.current, week: Date.today.cweek,
                                  state: "Clocked In",
                                  in_ip: "Admin-Clock-In")

    
      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?, 
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out,
                    in_ip: @shift.in_ip } }

      end
    end
  end
  
  def clock_out
     authorize @job, :clock_out?
    if @job.on_shift? && @job.current_shift.present?
        @shift = @job.current_shift
        @shift.update(time_out: Time.current,
                        state: "Clocked Out",
                        out_ip: "Admin-Clock-Out" )
    
      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?, 
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out.strftime("%l:%M%P"),
                    in_ip: @shift.in_ip } }

      end
    end
  end

  # GET /jobs/1/edit
  def edit

    @employees = @company.employees.unassigned

    authorize @job
  end

  # POST /jobs
  # POST /jobs.json
  def create
   
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      # @employee = Employee.create(employee_params)
      @job = @order.jobs.new(job_params)
      authorize @job
      # @job.order = @order
      # @employee = @job.create_employee(employee_params)
    else
      # @employee = Employee.create(employee_params)
      @job = Job.new(job_params)
      authorize @job
    end
    
    respond_to do |format|
      if @job.save
        format.html { redirect_to admin_job_path(@job, anchor: "job_#{@job.id}"), notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    authorize @job
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to admin_jobs_path(anchor: "job_#{@job.id}"), notice: 'Job was successfully created.' }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.includes(:employee, :order).find(params[:id])
      
      @employee = @job.employee
      @order = @job.order
      @company = @job.company
    end
    
    def pundit_user
      current_admin
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
