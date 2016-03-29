# == Schema Information
#
# Table name: direct_deposits
#
#  id                :integer          not null, primary key
#  employee_id       :integer
#  account_number    :string
#  routing_number    :string
#  acct_confirmation :string
#  admin_id          :string
#  effective_date    :datetime
#  account_type      :string           default("Checking")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_direct_deposits_on_employee_id  (employee_id)
#

class Admin::DirectDepositsController < ApplicationController
  before_action :set_direct_deposit, only: [:show, :edit, :update, :destroy]
  layout "admin_layout"
  # GET /direct_deposits
  # GET /direct_deposits.json
  def index
    @employee = Employee.find(params[:employee_id])
    @direct_deposits = @employee.direct_deposits.all
    skip_authorization
  end

  # GET /direct_deposits/1
  # GET /direct_deposits/1.json
  def show
  end

  # GET /direct_deposits/new
  def new
    @employee = Employee.find(params[:employee_id])
    @direct_deposit = DirectDeposit.new
    skip_authorization
  end

  # GET /direct_deposits/1/edit
  def edit
    
  end

  # POST /direct_deposits
  # POST /direct_deposits.json
  def create
    @employee = Employee.find(params[:employee_id])
    @direct_deposit = @employee.direct_deposits.new(direct_deposit_params)
    @direct_deposit.admin_id = current_admin.id
    skip_authorization
    respond_to do |format|
      if @direct_deposit.save
        format.html { redirect_to admin_employee_path(@employee), notice: 'Direct deposit was successfully created.' }
        format.json { render :show, status: :created, location: @direct_deposit }
      else
        format.html { render :new }
        format.json { render json: @direct_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /direct_deposits/1
  # PATCH/PUT /direct_deposits/1.json
  def update
    respond_to do |format|
      if @direct_deposit.update(direct_deposit_params)
        format.html { redirect_to admin_employee_path(@employee), notice: 'Direct deposit was successfully updated.' }
        format.json { render :show, status: :ok, location: @direct_deposit }
      else
        format.html { render :edit }
        format.json { render json: @direct_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /direct_deposits/1
  # DELETE /direct_deposits/1.json
  def destroy
    @direct_deposit.destroy
    respond_to do |format|
      format.html { redirect_to admin_employee_path(@employee), notice: 'Direct deposit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_direct_deposit
      @employee = Employee.find(params[:employee_id])
      @direct_deposit = DirectDeposit.find(params[:id])
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def direct_deposit_params
      params.require(:direct_deposit).permit(:employee_id, :account_number, :routing_number, :acct_confirmation, :admin_id, :effective_date, :account_type, :account_number_confirmation)
    end
end
