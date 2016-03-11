class Admin::TimesheetsController < ApplicationController
  before_action :set_timesheet, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!
	layout 'admin_layout'

    def index
        @test_timesheets = TimesheetQueryBuilder.new.with_admin_comments_by(@current_admin.id)
        if params[:job_id]
            @job = Job.includes(:employee, :timesheets).find(params[:job_id])
            @q = @job.timesheets.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee)
            @q.build_condition if @q.conditions.empty?
            @q.build_sort if @q.sorts.empty?
            gon.timesheets = @timesheets
            authorize @timesheets
        elsif params[:company_id]
            @company = Company.includes(:jobs, :timesheets).find(params[:company_id])
            @q = @company.timesheets.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee)
            @q.build_condition if @q.conditions.empty?
            @q.build_sort if @q.sorts.empty?
            gon.timesheets = @timesheets
            authorize @timesheets
        else
            @q = @current_admin.timesheets.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee)
            gon.timesheets = @timesheets
            authorize @timesheets
        end
        
        @scope = params[:scope]
        respond_to do |format|
            format.html
            if @company.present?
                if @scope == "current_week"
                    @pdf_timesheets = @company.timesheets.current_week.order(week: :asc).distinct
                    
                elsif @scope == "last_week"
                    @pdf_timesheets = @company.timesheets.last_week.order(week: :asc).distinct
                else
                    @pdf_timesheets = @company.timesheets.order(week: :asc).distinct
                end
                format.pdf {
                    send_data CompanyTimesheetPdf.new(@company, @pdf_timesheets, view_context, @scope, @signed_in).render,
                    filename: "#{@company.name}-#{@scope}-#{Time.current}.pdf",
                    type: "application/pdf",
                    disposition: :inline
                }
            else
                if @scope == "current_week"

                    @pdf_timesheets = @current_admin.timesheets.includes(job: [{ order: :company }]).current_week.order('companies.name').distinct
                elsif @scope == "last_week"
                    @pdf_timesheets = @current_admin.timesheets.includes(job: [{ order: :company }]).last_week.order('companies.name').distinct
                else
                    @pdf_timesheets = @current_admin.timesheets.order(week: :asc).distinct
                end
                format.pdf {
                    send_data AgencyTimesheetPdf.new(@current_agency, @pdf_timesheets, view_context,  @scope, @signed_in).render,
                    filename: "#{@current_agency.name}-#{@scope}-#{Time.current}.pdf",
                    type: "application/pdf",
                    disposition: :inline
                }
            
            end 
            @csv_timesheets = @pdf_timesheets
            format.csv { send_data @csv_timesheets.to_csv, filename: "timesheets-export-#{Time.now}-inclustaff.csv" }
            
            
        end
        
    end
	
	def past
		if params[:job_id]
			@job = Job.includes(:employee, :timesheets).find(params[:job_id])
			@q = @job.timesheets.past.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee)
		elsif params[:company_id]
			@company = Company.includes(:jobs, :timesheets).find(params[:company_id])
			@q = @company.timesheets.past.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee)
		else
			@q = Timesheet.past.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee)
		end
		Chronic.time_class = Time.zone
        @start_time = Chronic.parse(params[:date1])
        @end_time = Chronic.parse(params[:date2])
        if @start_time.present? && @end_time.present?
          @timesheets = Timesheet.occurring_between(@start_time, @end_time).distinct
        elsif @start_time.present?
          @timesheets = Timesheet.worked_after(@start_time).distinct
        elsif @end_time.present?
          @timesheets = Timesheet.worked_before(@end_time).distinct
        end
		gon.timesheets = @timesheets
		authorize @timesheets
		respond_to do |format|
      format.html
      format.csv { send_data @timesheets.distinct.to_csv, filename: "past-timesheets-export-#{Time.current}-inclustaff.csv" }
  	end 
	end
	
	def last_week
		@timesheets = Timesheet.last_week.distinct
		authorize @timesheets, :index?
		respond_to do |format|
      format.html
      format.csv { send_data @timesheets.to_csv, filename: "last-week-timesheets-export-#{Time.current}-#{@current_agency.name}.csv" }
  	end
	end

  def show
    authorize @timesheet
    @shifts = @timesheet.shifts
    @employee = @timesheet.employee
    @job = @timesheet.job
    @last_complete_shift = @timesheet.shifts.clocked_out.last
    @current_shift = @timesheet.shifts.clocked_in.last if @timesheet.clocked_in?
    gon.timesheet = @timesheet
    gon.shifts = @shifts
    gon.pay = @timesheet.gross_pay
    gon.status = @timesheet.shifts.last.state.titleize
    
    respond_to do |format|
      format.html
      format.json
      format.pdf {
        send_data TimesheetPdf.new(@timesheet, view_context).render,
          filename: "#{@timesheet.week_ending}-#{@employee.name}-timesheet.pdf",
          type: "application/pdf",
          disposition: :inline
      }
    end
    
  end

  def new
  end

  def approve
    @timesheet = Timesheet.find(params[:id])
    authorize @timesheet, :approve?
    if @timesheet.clocked_out?
      approved_by = @timesheet.approved? ? nil : current_admin.id
      approved_by_type = @timesheet.approved? ? nil : "Admin"
      state = @timesheet.approved? ? 'pending' : 'approved'
      @timesheet.update(approved_by: approved_by, approved_by_type: approved_by_type, state: state)
      user_approved = @timesheet.approved? ? @timesheet.user_approved : @timesheet.state
      current_admin.events.create(action: state, eventable: @timesheet)
     
      render json: { id: @timesheet.id, approved: @timesheet.approved?, name: @timesheet.employee.name,
                    state: @timesheet.state.upcase, user_approved: user_approved, clocked_in: @timesheet.clocked_in? }
    	else
      render json: { id: @timesheet.id, approved: @timesheet.approved?, clocked_in: @timesheet.clocked_in?, name: @timesheet.employee.name,
                    state: @timesheet.state.upcase, user_approved: user_approved }
    end
  end

  def edit
    @job = @timesheet.job
    authorize @timesheet
  end

  def create
    @timesheet = Timesheet.new(timesheet_params)
    @timesheet.shifts.last
    authorize @timesheet
    respond_to do |format|
      if @timesheet.save
        format.html { redirect_to admin_timesheets_path(@timesheet), notice: 'Timesheet was successfully created.' }
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
    @timesheet.update(timesheet_params)
    authorize @timesheet
    respond_to do |format|
      if @timesheet.update(timesheet_params)
        format.html { redirect_to admin_timesheet_path(@timesheet), notice: 'Timesheet was successfully updated.' }
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
      format.html { redirect_to admin_timesheets_path, notice: 'Timesheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def pundit_user
      current_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_timesheet
      @timesheet = Timesheet.find(params[:id])
      skip_authorization
    end
    
    def set_admin
      @admin = current_admin
      if @admin.agency?
        @agency = @admin.agency
      elsif @admin.company?
        @company = @admin.company
      end
        
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def timesheet_params
      params.require(:timesheet).permit(:week, :job_id, :reg_hours, :ot_hours, :gross_pay, 
        :shifts_attributes => [:id, :state, :job_id, :needs_adj, :employee_id, :note, 
        :time_in, :time_out, :break_out, :break_in, :break_duration, :in_ip, :out_ip, :_destroy])
    end
end
