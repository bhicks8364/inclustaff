class WorkHistoriesController < ApplicationController
  before_action :set_work_history, only: [:show, :edit, :update, :destroy]
  # layout 'admin_layout'
  # GET /work_histories
  # GET /work_histories.json
  def index
    @employee = current_user.employee if user_signed_in?
    @work_histories = @employee.work_histories.all
    skip_authorization
  end

  # GET /work_histories/1
  # GET /work_histories/1.json
  def show
    skip_authorization
  end

  # GET /work_histories/new
  def new
    @employee = current_user.employee if user_signed_in?
    @work_history = @employee.work_histories.new
    skip_authorization
  end

  # GET /work_histories/1/edit
  def edit
  end

  # POST /work_histories
  # POST /work_histories.json
  def create
    @current_user = current_user if user_signed_in?
    @employee = @current_user.employee if @current_user.present?
    
    @work_history = @employee.work_histories.new(work_history_params)
    skip_authorization

    respond_to do |format|
      if @work_history.save
        format.html { redirect_to @current_user, notice: 'Work history was successfully added.' }
        format.json { render :show, status: :created, location: @work_history }
      else
        format.html { render :new }
        format.json { render json: @work_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_histories/1
  # PATCH/PUT /work_histories/1.json
  def update
    respond_to do |format|
      if @work_history.update(work_history_params)
        format.html { redirect_to @work_history, notice: 'Work history was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_history }
      else
        format.html { render :edit }
        format.json { render json: @work_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_histories/1
  # DELETE /work_histories/1.json
  def destroy
    @work_history.destroy
    respond_to do |format|
      format.html { redirect_to work_histories_url, notice: 'Work history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_history
      @work_history = WorkHistory.find(params[:id])
      @employee = current_user.employee if user_signed_in?
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_history_params
      params.require(:work_history).permit(:employer_name, :start_date, :end_date, :title, :employee_id, :description, :current, :may_contact, :supervisor, :phone_number, :pay)
    end
end
