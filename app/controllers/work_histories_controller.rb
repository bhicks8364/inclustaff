# == Schema Information
#
# Table name: work_histories
#
#  id            :integer          not null, primary key
#  employee_id   :integer          not null
#  employer_name :string
#  title         :string
#  start_date    :date
#  end_date      :date
#  description   :text
#  current       :boolean          default(FALSE)
#  may_contact   :boolean          default(FALSE)
#  supervisor    :string
#  phone_number  :string
#  pay           :string
#

class WorkHistoriesController < ApplicationController
  before_action :set_work_history, only: [:show, :edit, :update, :destroy]
  layout :determine_layout
  # GET /work_histories
  # GET /work_histories.json
  def index
    if user_signed_in?
      @employee = current_user.employee if user_signed_in?
      @work_histories = @employee.work_histories.all
    elsif admin_signed_in?
      @work_histories = WorkHistory.all
    end
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
      @employee = @work_history.employee if @work_history.present?
      skip_authorization
    end
    def determine_layout
      if admin_signed_in?
        "admin_layout"
      elsif company_admin_signed_in?
        "company_layout"
      elsif user_signed_in?
        "employee"
      else
          "application"
      end
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def work_history_params
      params.require(:work_history).permit(:employer_name, :start_date, :end_date, :title, :employee_id, :description, :current, :may_contact, :supervisor, :phone_number, :pay, :tag_list)
    end
end
