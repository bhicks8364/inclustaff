class Employee::TimesheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_timesheet, only: [:show, :edit, :update, :destroy]
  layout 'employee'
  
  def index
    @current_user = current_user
    @employee = @current_user.employee
    @company = @employee.company
    @current_job = @employee.current_job if @employee.assigned?
    @q = @employee.timesheets.ransack(params[:q])
    @timesheets = @q.result.includes(:job, :employee)
    gon.timesheets = @timesheets
    authorize @timesheets
    # gon.jbuilder
    authorize @timesheets
    @pdf_timesheets = @timesheets
    @scoped_params = params[:q]
    respond_to do |format|
      format.html
      format.json
      format.pdf {
        # This is just a placeholder. Should be more like a paystub that employees can print/save
        send_data EmployeeTimesheetPdf.new(@employee, @pdf_timesheets, view_context, @scoped_params, @signed_in, @current_agency).render,
          filename: "#{@employee.name}-time-report.pdf",
          type: "application/pdf",
          disposition: "inline"
      }
    end
  end

  def show
    authorize @timesheet
    @job = @timesheet.job
    @shifts = @timesheet.shifts.order(time_in: :desc)
    @employee = @timesheet.employee
   
    @last_complete_shift = @timesheet.shifts.clocked_out.last
    @current_shift = @timesheet.shifts.clocked_in.last if @timesheet.clocked_in?
    respond_to do |format|
      format.html
      format.json
      format.pdf {
        # This is just a placeholder. Should be more like a paystub that employees can print/save
        send_data TimesheetPdf.new(@timesheet, view_context, @current_agency).render,
          filename: "#{@timesheet.week_ending}-#{@employee.name}-timesheet.pdf",
          type: "application/pdf",
          disposition: "inline"
      
      }
    end
  end

  # GET /timesheets/new
  def new
    @timesheet = Timesheet.new
    
    # authorize @timesheet
  end
  
  # def approve
    
  #   @timesheet.update(state: "approved", approved_by: current_admin.id) if @timesheet.clocked_out?
  #   # respond_to do |format|
  #   #   if @timesheet.save
  #   #     format.html { redirect_to @timesheet, notice: 'Timesheet was successfully created.' }
  #   #     format.json { render :show, status: :created, location: @timesheet }
  #   #   else
  #   #     format.html { render :new }
  #   #     format.json { render json: @timesheet.errors, status: :unprocessable_entity }
  #   #   end
  # end
  def approve
    @timesheet = Timesheet.find(params[:id])
    if @timesheet.clocked_out?
      approved_by = @timesheet.approved? ? nil : current_admin.id
      state = @timesheet.approved? ? 'pending' : 'approved'
      @timesheet.update(approved_by: approved_by, state: state)
      user_approved = @timesheet.approved? ? Admin.find(@timesheet.approved_by).name : @timesheet.state
      
      render json: { id: @timesheet.id, approved: @timesheet.approved?, 
                    state: @timesheet.state.titleize, user_approved: user_approved }
    end
  end

    
    

  # GET /timesheets/1/edit
  def edit
    # authorize @timesheet
  end

  # POST /timesheets
  # POST /timesheets.json
  def create
    @timesheet = Timesheet.new(timesheet_params)
    # authorize @timesheet

    respond_to do |format|
      if @timesheet.save
        format.html { redirect_to @timesheet, notice: 'Timesheet was successfully created.' }
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
        format.html { redirect_to @timesheet, notice: 'Timesheet was successfully updated.' }
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
    authorize @timesheet
    @timesheet.destroy
    respond_to do |format|
      format.html { redirect_to timesheets_url, notice: 'Timesheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timesheet
      @timesheet = Timesheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def timesheet_params
      params.require(:timesheet).permit(:week, :job_id, :reg_hours, :ot_hours, :gross_pay)
    end
end
