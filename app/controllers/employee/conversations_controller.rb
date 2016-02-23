class Employee::ConversationsController < ApplicationController
  before_action :skip_authorization

  layout 'employee'

  def index
    @conversations = current_user.mailbox.conversations
  end

  def show
    @conversation = current_user.mailbox.conversations.find(params[:id])
  end

  def new
    @admins = Admin.all
    @company = current_user.employee.company
    @company_admins = @company.admins.real_users
  end

  def create
    recipients = Admin.where(id: params[:admin_ids]).to_a +
      CompanyAdmin.where(id: params[:company_admin_ids]).to_a

    receipt   = current_user.send_message(recipients, params[:body], params[:subject])
    redirect_to employee_conversation_path(receipt.conversation)
  end
end
