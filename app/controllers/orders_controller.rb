class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  layout :determine_layout
  

  # GET /orders
  # GET /orders.json
  def index
    if admin_signed_in? && current_admin.company? 
      @admin = current_admin
      @company = @admin.company
      @timesheets = @company.timesheets.order(updated_at: :desc)
      @orders = @company.orders
      @with_active_jobs = @orders.with_active_jobs
    authorize @orders
    elsif user_signed_in? && current_user.not_an_employee?
      @current_user = current_user if current_user.present?
      @company = @current_user.company
      @orders = @company.orders
      @with_active_jobs = @orders.with_active_jobs
      @timesheets = @company.timesheets.order(updated_at: :desc)
    authorize @orders
    end
    
    
    

    
  end
  
  def all
    @q = Order.needs_attention.ransack(params[:q]) 
    @orders = @q.result(distinct: true).paginate(page: params[:page], per_page: 20)
    skip_authorization
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
    if admin_signed_in? 
      @admin = current_admin
      @company = @admin.company
      @order = @company.orders.new
    end
    
    # if params[:company_id]
    #   @company = Company.find(params[:company_id])
    #   @order = @company.orders.new
    #   # authorize @order

    # else
    #   @order = Order.new
    #   @order.jobs.build
    #   # authorize @order
    # end

  end

  # GET /orders/1/edit
  def edit
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @order = Order.find(params[:id])
      @order.jobs.build
      
      # authorize @order
    else
      @order = Order.find(params[:id])
      @order.jobs.build
      # authorize @order
    end
  end

  # POST /orders
  # POST /orders.json
  def create
      if params[:company_id]
        @company = Company.find(params[:company_id])
        @order = @company.orders.new(order_params)
      else
        @admin = current_admin
        @agency = @admin.agency
        @order = @agency.orders.new(order_params)
      end



    respond_to do |format|
      if @order.save 
        format.html { redirect_to company_order_path(@company, @order), notice: 'Order was successfully created.' }
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
    @company = Company.find(params[:company_id])
    # authorize @order
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
    def determine_layout
      if admin_signed_in?
        "admin_layout"
      elsif company_admin_signed_in?
        "company_layout"
      else
          "application"
      end
    end
  
    def pundit_user
      current_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_order

      @order = Order.find(params[:id])
          authorize @order
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :company_id, :manager_id, :title, :notes, :number_needed, :needed_by, :urgent, :active, jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active])
    end
end
