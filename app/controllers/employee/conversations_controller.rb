class Employee::ConversationsController < ApplicationController
  before_action :skip_authorization, :set_employee

  layout 'employee'

  def index
    @conversations = current_user.mailbox.conversations
  end

  def show
    @conversation = current_user.mailbox.conversations.find(params[:id])
  end

  def new
    @admins = @current_agency.admins.recruiters 
    @company = current_user.employee.company if @employee.assigned?
    @company_admins = @company.admins.real_users if @company.present?
  end

  def create
    recipients = Admin.where(id: params[:admin_ids]).to_a +
      CompanyAdmin.where(id: params[:company_admin_ids]).to_a

    receipt   = current_user.send_message(recipients, params[:body], params[:subject])
    if params[:redirect_to].present?
      redirect_to params[:redirect_to]
    else
      redirect_to employee_conversation_path(receipt.conversation)
    end
  end
  def set_employee
    @employee = @current_user.employee
  end
end
