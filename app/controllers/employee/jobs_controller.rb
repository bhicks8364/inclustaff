class Employee::JobsController < ApplicationController
  before_action :set_employee
  before_action :set_job, only: [:show, :edit, :update, :destroy, :clock_in, :clock_out]
  before_action :authenticate_user!
  layout 'employee'



  def index
    @jobs = @current_employee.jobs.order(created_at: :desc)
     
    authorize @jobs
  end
  
  def archived

  end

  def show
    
    @timesheet = @job.current_timesheet if @job.current_timesheet.present?
    @shift = @job.shifts.last if @job.shifts.any?
    @timesheets = @job.timesheets if @job.timesheets.any?
    @last_week_timesheets =  @job.timesheets.last_week
    @skills = @job.employee.skills
    # @order_skills = @job.order.skills
    
  end

  # GET /jobs/new
  

  def clock_in
    authorize @job, :clock_in?
    if @job.off_shift?
      @shift = @job.shifts.create(time_in: Time.current, week: Date.today.beginning_of_week.cweek,
                                  state: "Clocked In",
                                  in_ip: current_user.current_sign_in_ip)
      # current_user.events.create(action: "clocked_in", eventable: @shift.employee)

    
      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?, 
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out, last_out: @job.last_clock_out,
                    in_ip: @shift.in_ip, first_name: @job.employee.first_name } }

      end
    end
  end
  
  def clock_out
     authorize @job, :clock_out?
    if @job.on_shift? && @job.current_shift.present?
        @shift = @job.current_shift
        @shift.update(time_out: Time.current,
                        state: "Clocked Out",
                        out_ip: current_user.current_sign_in_ip, week: Date.today.beginning_of_week.cweek )
        # current_user.events.create(action: "clocked_out", eventable: @shift.employee)
      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?, 
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out.strftime("%l:%M%P"),
                    in_ip: @shift.in_ip, first_name: @job.employee.first_name } }

      end
    end
  end

  # GET /jobs/1/edit
  def edit
    
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @job = Job.find(params[:id])
      @employee = @job.employee
      @agency = @order.agency
      authorize @job
    elsif current_user.agency?
      @job = Job.includes(:employee, :order).find(params[:id])
      @company = @job.company
      @employee = @job.employee
      @order = @job.order
      @agency = @order.agency
       
      authorize @job
    end
   
    

    

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
    elsif params[:employee_id]
      @employee = Employee.find(params[:employee_id])
      @job = @employee.jobs.new(job_params)
      # @employee.mark_as_assigned!
      
      authorize @job
    else
      
      @job = Job.new(job_params)
      authorize @job
      
      @job.recruiter = current_user if current_user.recruiter?

      
    end
    
    respond_to do |format|
      if @job.save
        mentioned_admins = @job.mentioned_admins if @job.mentioned_admins
        
        mentioned_admins.each do |mentioned_admin|
          current_user.events.create(action: "mentioned", eventable: mentioned_admin)
        end
        
        format.html { redirect_to admin_job_path(@job), notice: 'Job was successfully created.' }
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
        
        mentioned_admins = @job.mentioned_admins if @job.mentioned_admins
        
        mentioned_admins.each do |mentioned_admin|
          current_user.events.create(action: "mentioned", eventable: mentioned_admin)
        end
        format.html { redirect_to admin_jobs_path(anchor: "mod_#{@job.id}"), notice: 'Job was successfully updated.' }
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
      @order = @job.order
      @company = @job.company
      authorize @job
     
    end
    def set_employee
        @user = current_user
        @employee = @user.employee
        
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
