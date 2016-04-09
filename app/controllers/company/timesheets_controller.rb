class Company::TimesheetsController < ApplicationController
  before_action :set_timesheet, only: [:show, :destroy, :approve, :edit, :update]
  before_action :authenticate_company_admin!
  layout 'company_layout'

  def index
    @admin = current_company_admin
    @company = @admin.company
    @job = Job.find(params[:job_id]) if params[:job_id]
    if @job.present?
      @q = @job.timesheets.ransack(params[:q])
      @timesheets = @q.result.includes(:job, :employee)
    else
      @q = @company.timesheets.ransack(params[:q])
      @timesheets = @q.result.includes(:job, :employee)
    end
    @import = Timesheet::Import.new
    gon.timesheets = @timesheets
    authorize @timesheets
    
    @scope = params[:scope]
    respond_to do |format|
      format.html
      if params[:scope] == "current_week"
        @pdf_timesheets = @company.timesheets.current_week.order(week: :asc).distinct
      elsif params[:scope] == "last_week"
        @pdf_timesheets = @company.timesheets.last_week.order(week: :asc).distinct
      else
        @pdf_timesheets = @company.timesheets.order(week: :asc).distinct
      end
      format.pdf {
        send_data CompanyTimesheetPdf.new(@company, @pdf_timesheets, view_context, @scope, @admin).render,
          filename: "#{@company.name}-#{params[:scope]}-#{Time.current}.pdf",
          type: "application/pdf",
          disposition: :inline
      }
       @csv_timesheets = @pdf_timesheets
      format.csv { send_data @csv_timesheets.to_csv, filename: "timesheets-export--#{params[:scope]}-#{Time.current}-inclustaff.csv" }
  	end 
 
  end
  def new
    @job = Job.find(params[:job_id]) if params[:job_id]
    if @job.present?
      @timesheet = @job.timesheets.new
    else
      @timesheet = Timesheet.new
    end
    @jobs = @current_company_admin.jobs.includes(:employee, :order)
    skip_authorization
  end

  def show
    # authorize @timesheet
    @shifts = @timesheet.shifts.order(time_in: :desc)
    @employee = @timesheet.employee
    @job = @timesheet.job
    @last_complete_shift = @timesheet.shifts.clocked_out.last
    @current_shift = @timesheet.shifts.clocked_in.last if @timesheet.clocked_in?
    gon.timesheet = @timesheet
    gon.pay = @timesheet.gross_pay
    gon.status = @timesheet.shifts.last.state.titleize if @timesheet.shifts.any?
    respond_to do |format|
      format.html
      format.json
      format.pdf {
        send_data TimesheetPdf.new(@timesheet, view_context, @current_agency).render,
          filename: "#{@timesheet.week_ending}-#{@employee.name}-timesheet.pdf",
          type: "application/pdf",
          disposition: :inline
      }
    end
  end


  def approve
    @timesheet = Timesheet.find(params[:id])
    authorize @timesheet, :approve?
    if @timesheet.clocked_out?
      approved_by = @timesheet.approved? ? nil : current_company_admin.id
      approved_by_type = @timesheet.approved? ? nil : "CompanyAdmin"
      state = @timesheet.approved? ? 'pending' : 'approved'
      @timesheet.update(approved_by: approved_by, approved_by_type: approved_by_type, state: state)
      user_approved = @timesheet.approved? ? @timesheet.user_approved : @timesheet.state
      current_company_admin.events.create(action: state, eventable: @timesheet)
     
      render json: { id: @timesheet.id, approved: @timesheet.approved?, name: @timesheet.employee.name,
                    state: @timesheet.state.upcase, user_approved: user_approved, clocked_in: @timesheet.clocked_in? }
    	else
      render json: { id: @timesheet.id, approved: @timesheet.approved?, clocked_in: @timesheet.clocked_in?, name: @timesheet.employee.name,
                    state: @timesheet.state.upcase, user_approved: user_approved }
    end
  end

  def import
      @import  = Timesheet::Import.new(timesheet_import_params)
      if @import.save
        @q = @current_company_admin.timesheets.ransack(params[:q])
        @timesheets = @current_company_admin.timesheets
        redirect_to company_timesheets_path, notice: "Imported #{@import_count} timesheets."
      else
        @q = @current_company_admin.timesheets.ransack(params[:q])
        @timesheets = @current_company_admin.timesheets
        flash[:alert] = "There were errors with your CSV file."
        render action: :index
      end
      skip_authorization
      
  end
  
  def approve_all
    @timesheets = @current_company_admin.timesheets.pending
    @timesheet_count = @timesheets.count
    @timesheets.each do |timesheet|
      approved_by = timesheet.approved? ? nil : current_company_admin.id
      approved_by_type = timesheet.approved? ? nil : "CompanyAdmin"
      state = timesheet.approved? ? 'pending' : 'approved'
      timesheet.update(approved_by: approved_by, approved_by_type: approved_by_type, state: state)
      current_company_admin.events.create(action: state, eventable: timesheet)
    end
    @q = @current_company_admin.timesheets.ransack(params[:q])
    @timesheets = @current_company_admin.timesheets
    @import = Timesheet::Import.new
    render action: :index, notice: "You approved #{@timesheet_count} timesheets."
    skip_authorization
  end
    

  # GET /timesheets/1/edit
  def edit
    
  end

  # POST /timesheets
  # POST /timesheets.json
  def create
    @job = Job.find(params[:job_id]) if params[:job_id]
    if @job.present?
      @timesheet = @job.timesheets.new(timesheet_params)
    else
      @timesheet = Timesheet.new(timesheet_params)
    end
    # authorize @timesheet

    skip_authorization
    respond_to do |format|
      if @timesheet.save
        format.html { redirect_to company_timesheet_path(@timesheet), notice: 'Timesheet was successfully created.' }
        format.json { render :show, status: :created, location: @timesheet }
      else
        format.html { render :new }
        format.json { render json: @timesheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /timesheets/1
  # PATCH/PUT /timesheets/1.json
  def update
    # authorize @timesheet
    respond_to do |format|
      if @timesheet.update(timesheet_params)
        format.html { redirect_to company_timesheet_path(@timesheet), notice: 'Timesheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @timesheet }
      else
        format.html { render :edit }
        format.json { render json: @timesheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timesheets/1
  # DELETE /timesheets/1.json
  def destroy
    
    @timesheet.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Timesheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def pundit_user
    current_company_admin
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_timesheet
    @timesheet = Timesheet.find(params[:id])
    skip_authorization
    # authorize @timesheet
  end
  def timesheet_import_params
    params.require(:timesheet_import).permit(:file)
  end
    # Never trust parameters from the scary internet, only allow the white list through.
  def timesheet_params
    params.require(:timesheet).permit(:week, :job_id, :reg_hours, :ot_hours, :gross_pay, 
      :shifts_attributes => [:id, :state, :job_id, :needs_adj, :employee_id, :note, 
      :time_in, :time_out, :break_out, :break_in, :break_duration, :in_ip, :out_ip, :_destroy])
  end
end
