class Employee::WorkHistoriesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_employee
  before_action :set_work_history, only: [:show, :edit, :update, :destroy]
  layout 'employee'

  def index
      @work_histories = @employee.work_histories
      authorize @work_histories
  end
  
  def show
   
  end

  def new
    @work_history = @employee.work_histories.new
    authorize @work_history
  end

  def edit
  end

  def create
    @work_history = @employee.work_histories.new(work_history_params)
    authorize @work_history

    respond_to do |format|
      if @work_history.save
        format.html { redirect_to employee_work_histories_path, notice: 'Work history was successfully created.' }
        format.json { render :show, status: :created, location: @work_history }
      else
        format.html { render :new }
        format.json { render json: @work_history.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @work_history.update(work_history_params)
        format.html { redirect_to employee_work_histories_path, notice: 'Work history was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_history }
      else
        format.html { render :edit }
        format.json { render json: @work_history.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @work_history.destroy
    respond_to do |format|
      format.html { redirect_to employee_work_histories_url, notice: 'Work history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
  # def pundit_user
  #   current_user
  # end
    # Use callbacks to share common setup or constraints between actions.
    def set_work_history
  
      @work_history = WorkHistory.find(params[:id])
      authorize @work_history
    end
    def set_employee
      @user = current_user
      @employee = @user.employee
      
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def work_history_params
      params.require(:work_history).permit(:employer_name, :start_date, :end_date, :title, :employee_id, :description, :current, :may_contact, :supervisor, :phone_number, :pay)
    end
end
