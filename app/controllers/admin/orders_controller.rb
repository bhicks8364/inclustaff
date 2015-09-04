class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_admin!

  

  # GET /orders
  # GET /orders.json
  def index

      @admin = current_admin
      @company = @admin.company
      @orders = @company.orders.active
      # @timesheets = @company.timesheets.order(updated_at: :desc)
      # @orders = @company.orders
      # @with_active_jobs = @orders.with_active_jobs

  end
  
  def all

      @admin = current_admin
      @company = @admin.company
      # @timesheets = @company.timesheets.order(updated_at: :desc)
      @orders = @company.orders
      # @with_active_jobs = @orders.with_active_jobs
    
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @company = @order.company
    @inactivejobs = @order.jobs.inactive
    @active_jobs = @order.jobs.active
    @jobs = @order.jobs.active.includes(:shifts)
    # authorize @order
  end
    

  # GET /orders/new
  def new
    @admin = current_admin
    @company = @admin.company
    @account_managers = @company.account_managers
    @order = @company.orders.new

  end

  # GET /orders/1/edit
  def edit
      @order = Order.find(params[:id])
      @company = @order.company
      @account_managers = @company.account_managers
      @order.jobs.build

  end

  # POST /orders
  # POST /orders.json
  def create

    @admin = current_admin
    @company = @admin.company
    @order = @company.orders.new(order_params)



    respond_to do |format|
      if @order.save 
        format.html { redirect_to admin_order_path(@order), notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    @company = @order.company

    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to company_order_path(@company, @order), notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    authorize @order
    @order.destroy

    respond_to do |format|
      format.html { redirect_to company_orders_path(@company), notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order

      @order = Order.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :company_id, :account_manager_id, :manager_id, :title, :pay_range, :notes, :number_needed, :needed_by, :urgent, :active, jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active])
    end
end
