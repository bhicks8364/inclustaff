class Employee::ConversationsController < ApplicationController
  before_action :skip_authorization, :set_employee

  layout 'employee'

  def index
    @conversations = current_user.mailbox.conversations
  end
  
  def inbox
    @conversations = current_user.mailbox.inbox
    render action: :index
  end

  def sent
    @conversations = current_user.mailbox.sentbox
    render action: :index
  end

  def trash
    @conversations = current_user.mailbox.trash
    render action: :index
  end

  def show
    @conversation = current_user.mailbox.conversations.find(params[:id])
    @conversation.mark_as_read(current_user)
  end
  
  def mark_as_unread
    @conversation = current_user.mailbox.conversations.find(params[:id])
    if @conversation.is_read?(current_user) 
      @conversation.mark_as_unread(current_user) 
    else
      @conversation.mark_as_read(current_user)
    end
    @color = @conversation.is_read?(current_user) ? "read" : "unread"
    @icon = @conversation.is_read?(current_user) ? "<i class='fa fa-envelope'></i>".html_safe : "<i class='fa fa-envelope-o'></i>".html_safe
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
