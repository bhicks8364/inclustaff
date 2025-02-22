class Admin::InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]
  layout "admin_layout"

  def index
    if params[:company_id]
      @company = Company.includes(:invoices).find(params[:company_id])
      @invoices = @company.invoices.order(week: :desc).paginate(:page => params[:page], :per_page => 10).distinct
    else
      @q = @current_admin.invoices.ransack(params[:q])
        @invoices = @q.result.order(week: :desc).page(params[:page])
      # @invoices = @current_agency.invoices.includes(:company).order(week: :desc).paginate(:page => params[:page], :per_page => 30).distinct
    end
    skip_authorization
  end

  def show
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @invoice = Invoice.find(params[:id])
    else
      @invoice = Invoice.find(params[:id])
      @company = @invoice.company
    end
    @week = @invoice.timesheets.last.week
    @company_name = @invoice.company.name
    @id = @invoice.id
    respond_to do |format|
      format.html
      format.json
      format.pdf {
        send_data @invoice.agency_copy(view_context).render,
          filename: "#{@week}-#{@company_name}_INV##{@id}-candidate-sheet.pdf",
          type: "application/pdf",
          disposition: :inline
      }
    end
    skip_authorization
  end

  def new
    @company = Company.find(params[:company_id])
    @invoice = @company.invoices.new
    skip_authorization
  end

  def edit
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @invoice = Invoice.find(params[:id])
    else
      @invoice = Invoice.find(params[:id])
      render 'invoices/edit'
    end
    skip_authorization
  end

  def create
    @company = Company.find(params[:company_id]) if params[:company_id]
    @invoice = @company.invoices.new(invoice_params)
    @invoice.agency = @current_agency
    skip_authorization
    respond_to do |format|
      if @invoice.save
        @company = @invoice.company
        format.html { redirect_to admin_company_invoice_path(@company, @invoice), notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def mark_as_paid
    @invoice = Invoice.find(params[:id])
    @company = @invoice.company
    if @invoice.timesheets_approved?
      @invoice.mark_as_paid! 
    end
      skip_authorization
    respond_to do |format|
      if @invoice.paid
        format.html { redirect_to admin_company_invoice_path(@company, @invoice), notice: 'Marked as paid!'}
        format.js
      else
        format.html { redirect_to admin_company_invoice_path(@company, @invoice), notice: 'Unable to marked as paid! Make sure all timesheets are approved first.'}
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        @company = @invoice.company
        format.html { redirect_to admin_company_invoice_path(@company, @invoice), notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @company = @invoice.company
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to admin_company_invoices_path(@company), notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
      skip_authorization
    end
    
    def invoice_params
      params.require(:invoice).permit(:company_id, :agency_id, :week, :due_by, :paid, :total, :amt_paid, :date_paid)
    end
end
