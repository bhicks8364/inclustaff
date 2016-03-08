class Admin::JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :clock_in, :clock_out, :cancel]
  before_action :authenticate_admin!
  layout 'admin_layout'



  def index
    @jobs = @current_admin.jobs.where(state: "Currently Working").includes(:employee)
    if params[:employee_id]
      @employee = Employee.find(params[:employee_id])
      @jobs = @employee.jobs.where(state: "Currently Working")
    else

      @q = Job.includes(:employee, :recruiter).order(created_at: :desc).ransack(params[:q])  if @current_agency.present?
      @q = @current_admin.jobs.includes(:employee).order(created_at: :desc).ransack(params[:q])  if @current_admin.recruiter?
      if params[:q].present?
        @jobs = @q.result(distinct: true).paginate(page: params[:page], per_page: 5)
      end
      
      authorize @jobs
    end



  end

  def inactive
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @jobs = @order.jobs.inactive
    else
      @jobs = @current_agency.jobs.inactive
    end
    authorize @jobs, :index?
  end

  def show
    @timesheet = @job.current_timesheet if @job.current_timesheet.present?
    @timesheets = @job.timesheets if @job.timesheets.any?
    @last_week_timesheets =  @job.timesheets.last_week
    @skills = @job.employee.skills
  
    respond_to do |format|
      format.html
      format.json
      format.pdf {
        send_data @job.candidate_sheet.render,
          filename: "#{@job.title_company}-#{@employee.name}-candidate-sheet.pdf",
          type: "application/pdf",
          disposition: :inline
      }
    end
  end

  def approve
    # This will throw an error if the job is not pending
    # Should be creating a new job if reassigning
    @job = Job.pending_approval.find(params[:id])
    authorize @job
    @employee = @job.employee

    @job.update(active: true, state: "Currently Working")
    @employee.update(assigned: true)
    current_admin.events.create(action: "approved", eventable: @job, user_id: @employee.user_id)

    respond_to do |format|
      format.json { render json: { id: @job.id, approved: @job.active?, name: @employee.name, status: @job.status, state: @job.state } }
    end
  end

  def cancel
    if @job.active? && @job.shifts.any?
      @job.update(active: false, end_date: Date.today, state: "Assignment Ended")
      @employee.update(assigned: false)
      # It'd be nice to have them be required to give a reason when ending an assignment
      # Like just a comment and/or choices (hired-in, quit, ncns, laid-off, fired)
      # ** choices would make employment verifications easier
      current_admin.events.create(action: "canceled", eventable: @job, user_id: @employee.user_id)
      respond_to do |format|
        format.json { render json: { id: @job.id, approved: @job.active?, name: @employee.name, status: @job.status, ended: @job.end_date.stamp('11/12/2016'), state: @job.state } }
      end
    elsif @job.pending_approval? && !@employee.available?
      @job.update(active: false, state: "Already Working")
      current_admin.events.create(action: "declined", eventable: @job, user_id: @employee.user_id)
      respond_to do |format|
        format.json { render json: { id: @job.id, approved: @job.active?, name: @employee.name, status: @job.status, state: @job.state } }
      end
    else
      @job.update(active: false, state: "Declined by agency")
      current_admin.events.create(action: "declined", eventable: @job, user_id: @employee.user_id)
      respond_to do |format|
        format.json { render json: { id: @job.id, approved: @job.active?, name: @employee.name, status: @job.status, state: @job.state } }
      end
    end

  end

  # GET /jobs/new
  def new
    if @current_agency.admins.recruiters.count == 0
      redirect_to new_admin_admin_path, notice: "Please add a recruiter before making a placement."
    end
    @admin = current_admin
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      @agency = @order.agency
      @job = @order.jobs.new
      authorize @job
    elsif params[:employee_id]
      @employee = Employee.find(params[:employee_id])
      @job = @employee.jobs.new
      authorize @job
    else
      @job = Job.new
      authorize @job
    end

  end

  def clock_in
    authorize @job, :clock_in?
    if @job.off_shift?
      @shift = @job.shifts.create(time_in: Time.current, week: Date.today.beginning_of_week.cweek,
                                  state: "Clocked In",
                                  in_ip: current_admin.current_sign_in_ip)
      current_admin.events.create(action: "clocked_in", eventable: @shift, user_id: @shift.employee.user_id)


      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?,
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out, last_out: @job.last_clock_out,
                    in_ip: @shift.in_ip, first_name: @job.employee.first_name, new_count: current_admin.jobs.on_shift.count } }

      end
    end
  end

  def clock_out
     authorize @job, :clock_out?
    if @job.on_shift? && @job.current_shift.present?
        @shift = @job.current_shift
        @shift.update(time_out: Time.current,
                        state: "Clocked Out", week: Date.today.beginning_of_week.cweek,
                        out_ip: current_admin.current_sign_in_ip )
        current_admin.events.create(action: "clocked_out", eventable: @shift, user_id: @shift.employee.user_id)
      respond_to do |format|
          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?,
                    state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out.strftime("%l:%M%P"),
                    in_ip: @shift.in_ip, first_name: @job.employee.first_name, new_count: current_admin.jobs.on_shift.count } }

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
    elsif current_admin.agency?
      @job = Job.includes(:employee, :order).find(params[:id])
      @company = @job.company
      @employee = @job.employee
      @order = @job.order
      @agency = @order.agency


      authorize @job
    end
   gon.admins = @current_agency.admins
    gon.users = @current_agency.users.available
    gon.admins_display = @company.account_managers.map(&:mention_data)
    gon.company_admins_display = @company.admins.map(&:mention_data)



  end

  # POST /jobs
  # POST /jobs.json
  def create
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      @job = @order.jobs.new(job_params)
      authorize @job
    elsif params[:employee_id]
      @employee = Employee.find(params[:employee_id])
      @job = @employee.jobs.new(job_params)
      authorize @job
    else
      @job = Job.new(job_params)
      authorize @job
    end
    if sending_for_approval?
      @job.active = false
      @job.state = "Pending Approval"
      current_admin.events.create(action: "presented", eventable: @job)
    else
      @job.state = "Currently Working"
    end

    respond_to do |format|
      if @job.save
        mentioned_admins = @job.mentioned_admins if @job.mentioned_admins
        mentioned_admins.each do |mentioned_admin|
          current_admin.events.create(action: "mentioned", eventable: mentioned_admin)
          # @job.send_notifications!
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
          current_admin.events.create(action: "mentioned", eventable: mentioned_admin)
        end
        format.html { redirect_to admin_job_path(@job), notice: 'Job was successfully updated.' }
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
      format.html { redirect_to admin_jobs_path, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def sending_for_approval?
    params[:commit] == "Send for Approval"
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.includes(:employee, :order, :shifts).find(params[:id])
      authorize @job
      @employee = @job.employee
      @order = @job.order
      @agency = @order.agency
      @company = @job.company
    end

    def pundit_user
      current_admin
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:order, :recruiter_id, :title, :active, :description,
      :start_date, :pay_rate, :end_date, :order_id, :employee_id, :drive_pay, :ride_pay, :state,
      :number_of_days, :milestone_1, :milestone_2, :milestone_3)
    end

end
