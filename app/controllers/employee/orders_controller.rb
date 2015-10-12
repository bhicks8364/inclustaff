class Employee::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :apply]
  before_action :authenticate_user!
  layout 'application'

  # GET /orders
  # GET /orders.json
  def index
    if user_signed_in? && current_user.employee?
      @current_user = current_user if current_user.present?
      @employee = @current_user.employee
      @orders = Order.needs_attention.order(:needed_by)
      
      
     skip_authorization
    end
    
    
    

    
  end
  
  
  # GET /orders/1
  # GET /orders/1.json
  def show
    skip_authorization
  end
  
  def apply

      @current_user.events.create(action: "applied", eventable: @order)
      @order.update(updated_at: Time.current)


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


 
  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to order_path(@order), notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  
  private
  
    def pundit_user
      current_user
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_order

      @order = Order.includes(:company, :agency).find(params[:id])
      @company = @order.company
      @agency = @order.agency
      @current_user = current_user if current_user.present?
      @employee = @current_user.employee
      skip_authorization
          # authorize @order
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :company_id, :manager_id, :title, :pay_range, :notes, :number_needed, :needed_by, :urgent, :active, jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active])
    end

end
