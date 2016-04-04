class Admin::TimesheetsController < ApplicationController
  before_action :set_timesheet, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!
	layout 'admin_layout'

    def index
        @test_timesheets = TimesheetQueryBuilder.new.with_admin_comments_by(@current_admin.id)
        if params[:job_id]
            @job = Job.includes(:employee, :timesheets).find(params[:job_id])
            @q = @job.timesheets.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee).paginate(page: params[:page], per_page: 10)
        elsif params[:company_id]
            @company = Company.includes(:jobs, :timesheets).find(params[:company_id])
            @q = @company.timesheets.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee).paginate(page: params[:page], per_page: 10)
            
        else
            @q = @current_admin.timesheets.ransack(params[:q])
            @timesheets = @q.result.includes(:job, :employee).paginate(page: params[:page], per_page: 10)
        end
        authorize @timesheets
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
        # render action: :index
		gon.timesheets = @timesheets
		authorize @timesheets
		respond_to do |format|
      format.html
      format.csv { send_data @timesheets.distinct.to_csv, filename: "past-timesheets-export-#{Time.current}-inclustaff.csv" }
  	end 
	end
	
	def last_week
	    @q = @current_admin.timesheets.last_week.ransack(params[:q])
        @timesheets = @q.result.includes(:job, :employee).paginate(page: params[:page], per_page: 10)
        gon.timesheets = @timesheets
       
        authorize @timesheets, :index?
# 		@timesheets = Timesheet.last_week.distinct
# 		authorize @timesheets, :index?
		respond_to do |format|
          format.html
          format.csv { send_data @timesheets.to_csv, filename: "last-week-timesheets-export-#{Time.current}-#{@current_agency.name}.csv" }
      	end
	end

  def show
    authorize @timesheet
    @employee = @timesheet.employee
    @job = @timesheet.job
    if @timesheet.shifts.any?
        @shifts = @timesheet.shifts
        @last_complete_shift = @shifts.clocked_out.last
        @current_shift = @shifts.clocked_in.last if @timesheet.clocked_in?
        gon.timesheet = @timesheet
        gon.shifts = @shifts
        gon.pay = @timesheet.gross_pay
        gon.status = @timesheet.state
    end
    
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

  def new
      
      if params[:job_id]
          @job = Job.find(params[:job_id])
          @timesheet = @job.timesheets.new
          @redirect_to = admin_job_timesheets_path(@job)
      else
          @timesheet = Timesheet.new
          @redirect_to = edit_multiple_admin_timesheets_path
      end
      skip_authorization
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
        respond_to do |format|
            if @timesheet.save
                format.js
                format.json {render json: { id: @timesheet.id, approved: @timesheet.approved?, name: @timesheet.employee.name,
                            state: @timesheet.state.upcase, user_approved: user_approved, clocked_in: @timesheet.clocked_in? }}
            else
                format.js
                format.json {render json: { id: @timesheet.id, approved: @timesheet.approved?, clocked_in: @timesheet.clocked_in?, name: @timesheet.employee.name,
                            state: @timesheet.state.upcase, user_approved: user_approved }}
            end
        end
    end
  end

  def edit
    @job = @timesheet.job
    @employee = @timesheet.employee
    skip_authorization
    # authorize @timesheet
  end

  def create
      if params[:job_id]
          @job = Job.find(params[:job_id])
          @timesheet = @job.timesheets.new(timesheet_params)
          week_start = @timesheet.week.beginning_of_week
        @timesheet.week = week_start
      else
          @timesheet = Timesheet.new(timesheet_params)
          week_start = @timesheet.week.beginning_of_week
            @timesheet.week = week_start
      end
    
    skip_authorization
    respond_to do |format|
      if @timesheet.save
          if params[:redirect_to].present?
              format.html { redirect_to admin_job_timesheets_path(@timesheet.job, anchor: "timesheet_#{@timesheet.id}"), notice: 'Timesheet was successfully updated.' }
          else
              format.html { redirect_to admin_job_timesheets_path(@timesheet.job, anchor: "timesheet_#{@timesheet.id}"), notice: 'Timesheet was successfully updated.' }
          end
        format.json { render :show, status: :created, location: @timesheet }
      else
        format.html { render :new }
        format.json { render json: @timesheet.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit_multiple
    #   @companies = @current_agency.companies.with_current_timesheets.order("companies.name").distinct
    @redirect_to = edit_multiple_admin_timesheets_path
    
    @q = @current_agency.timesheets.includes(:job, :order, :company).order(week: :asc).last_week.distinct.ransack(params[:q])
    @timesheets = @q.result.includes(:job, :employee).paginate(page: params[:page], per_page: 10)
    @approved_timesheets = @current_agency.timesheets.includes(:job, :order, :company).order(week: :asc).last_week.approved.distinct.paginate(page: params[:page], per_page: 10)
    @pending_timesheets = @current_agency.timesheets.includes(:job, :order, :company).order(week: :asc).last_week.pending.distinct.paginate(page: params[:page], per_page: 10)
    skip_authorization
  end
  
  def update_multiple
      skip_authorization
  end

  # PATCH/PUT /timesheets/1
  # PATCH/PUT /timesheets/1.json
  def update
      
    @timesheet.update(timesheet_params)
    week_start = @timesheet.week.beginning_of_week
    @timesheet.week = week_start
    authorize @timesheet
    respond_to do |format|
      if @timesheet.update(timesheet_params)
          if params[:redirect_to].present?
              format.html { redirect_to edit_multiple_admin_timesheets_path(anchor: "timesheet_#{@timesheet.id}"), notice: 'Timesheet was successfully updated.' }
          else
              format.html { redirect_to admin_job_timesheets_path(@timesheet.job, anchor: "timesheet_#{@timesheet.id}"), notice: 'Timesheet was successfully updated.' }
          end
        format.json { render :show, status: :ok, location: @timesheet }
      else
        format.html { render :edit }
        format.json { render json: @timesheet.errors, status: :unprocessable_entity }
      end
    end
  end
  def delete_all_shifts
      @timesheet = Timesheet.find(params[:timesheet_id])
      @shifts = @timesheet.shifts
      @shifts.map(&:destroy)
      @timesheet.update(state: "pending")
      skip_authorization
      redirect_to edit_multiple_admin_timesheets_path(anchor: "timesheet_#{@timesheet.id}"), notice: 'Timesheet was successfully updated.' 
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
      @company = @timesheet.company
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
      params.require(:timesheet).permit(:week, :job_id, :reg_hours, :ot_hours, :gross_pay, :reg_bill_rate, :ot_bill_rate, 
        :shifts_attributes => [:id, :state, :job_id, :needs_adj, :employee_id, :note, 
        :time_in, :time_out, :break_out, :break_in, :break_duration, :in_ip, :out_ip, :_destroy])
    end
end
