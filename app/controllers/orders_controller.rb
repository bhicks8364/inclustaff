class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_company, only: [:index]
  

  # GET /orders
  # GET /orders.json
  def index
    
    @orders = @company.orders
    @with_active_jobs = @orders.with_active_jobs
    authorize @orders
    
  end
  
  def all
    @orders = Order.all
    authorize @orders
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @company = @order.company
    @inactivejobs = @order.jobs.inactive
    @active_jobs = @order.jobs.active
    authorize @order
  end
    

  # GET /orders/new
  def new
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @order = @company.orders.new
      authorize @order

    else
      @company = current_user.company
      @order = @company.orders.new
      authorize @order
    end

  end

  # GET /orders/1/edit
  def edit
    if params[:company_id]
      @company = Company.find(params[:company_id])
      authorize @order
    else
      @order = Order.find(params[:id])
      authorize @order
    end
  end

  # POST /orders
  # POST /orders.json
  def create
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @order = @company.orders.new(order_params)
      authorize @order

    else
      @company = current_user.company
      @order = @company.orders.new(order_params)
      authorize @order
    end


    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
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
    authorize @order
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to [@company, @order], notice: 'Order was successfully updated.' }
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
    def set_company
      @company = Company.find(params[:company_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :company_id, :manager_id, :title, :pay_range, :notes, :number_needed, :needed_by, :urgent, :active, jobs_attributes: [:title, :description, :start_date, :id, :employee_id])
    end
end
