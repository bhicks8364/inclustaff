class Admin::JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :clock_in]
  before_action :authenticate_admin!
  # before_action :set_order

  # GET /jobs
  # GET /jobs.json
  def index
    @admin = current_admin
    @company = @admin.company
    @jobs = @company.jobs.order(title: :asc)

  end
  
  def archived
    @company = current_user.company if current_user.present?
    @archived_jobs = @company.jobs.inactive.with_employee
    @active_jobs = Job.active.with_employee
    # authorize @active_jobs
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show

    @employee = @job.employee
    @order = @job.order
    @current_timesheet = @job.current_timesheet
    @company = @job.company
    @current_shift = @job.shifts.clocked_in.last if @job.on_shift?
    @all_timesheets = @job.timesheets
    @timesheets = @job.timesheets
    @last_week_timesheets =  @job.timesheets.last_week
    
  end

  # GET /jobs/new
  def new

    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      @job = @order.jobs.new

    else
      @company = current_admin.company
      @orders = @company.orders

    
      @job = @job = Job.new

    end


  end

  def clock_in

    if @job.off_shift?
      @job.clock_in!
      @shift = @job.current_shift

    
      respond_to do |format|
          format.js

      end
    end
  end

  # GET /jobs/1/edit
  def edit
    @company = @job.company
    @employees = @company.employees.unassigned
    @order = @job.order
    @employee = @job.employee
    # authorize @job
  end

  # POST /jobs
  # POST /jobs.json
  def create
   
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      # @employee = Employee.create(employee_params)
      @job = @order.jobs.new(job_params)
      # authorize @job
      # @job.order = @order
      # @employee = @job.create_employee(employee_params)
    else
      # @employee = Employee.create(employee_params)
      @job = Job.new(job_params)
      # authorize @job
    end
    
    respond_to do |format|
      if @job.save
        format.html { redirect_to job_path(@job, anchor: "job_#{@job.id}"), notice: 'Job was successfully created.' }
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
    # authorize @job
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
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
