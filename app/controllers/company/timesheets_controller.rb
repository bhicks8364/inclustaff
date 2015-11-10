class Company::TimesheetsController < ApplicationController
  before_action :set_timesheet, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_company_admin!
  # GET /timesheets
  # GET /timesheets.json
  def index

    @admin = current_company_admin
    @company = @admin.company
    @timesheets = @company.timesheets.order(updated_at: :desc)
    gon.timesheets = @timesheets
    respond_to do |format|
      format.html
      format.csv { send_data @timesheets.to_csv, filename: "timesheets-export-#{Time.now}-inclustaff.csv" }
  	end 
 
  end

  # GET /timesheets/1
  # GET /timesheets/1.json
  def show
    # authorize @timesheet
    @shifts = @timesheet.shifts.order(time_in: :desc)
    @employee = @timesheet.employee
    @job = @timesheet.job
    @last_complete_shift = @timesheet.shifts.clocked_out.last
    @current_shift = @timesheet.shifts.clocked_in.last if @timesheet.clocked_in?
    gon.timesheet = @timesheet
    gon.pay = @timesheet.gross_pay
    gon.status = @timesheet.shifts.last.state.titleize
    respond_to do |format|
      format.html
      format.json
      format.pdf {
        send_data @timesheet.receipt.render,
          filename: "#{@timesheet.week_ending}-#{@employee.name}-timesheet.pdf",
          type: "application/pdf",
          disposition: :inline
      }
    end
  end

  # GET /timesheets/new
  def new
    @timesheet = Timesheet.new
    
    # authorize @timesheet
  end
 
  def approve
    @timesheet = Timesheet.find(params[:id])
    if @timesheet.clocked_out?
      approved_by = @timesheet.approved? ? nil : current_company_admin.id
      approved_by_type = @timesheet.approved? ? nil : "CompanyAdmin"
      state = @timesheet.approved? ? 'pending' : 'approved'
      @timesheet.update(approved_by: approved_by, approved_by_type: approved_by_type, state: state)
      current_company_admin.events.create(action: state, eventable: @timesheet)
      user_approved = @timesheet.approved? ? @timesheet.user_approved : @timesheet.state
      
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
