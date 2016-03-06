class Company::ConversationsController < ApplicationController
  before_action :skip_authorization, :set_company

  layout 'company_layout'

  def index
    @users = @current_company.employees
    @conversations = current_company_admin.mailbox.conversations
    gon.candidates = @current_company.jobs.pending_approval
    gon.employees = @company.employees.map(&:mention_data)
    gon.admins_display = @admins.map(&:mention_data)
    gon.company_admins_display = @current_company.admins.map(&:mention_data)
  end
  def inbox
    @conversations = current_company_admin.mailbox.inbox
    render action: :index
  end

  def sent
    @conversations = current_company_admin.mailbox.sentbox
    render action: :index
  end

  def trash
    @conversations = current_company_admin.mailbox.trash
    render action: :index
  end

  def show
    @conversation = current_company_admin.mailbox.conversations.find(params[:id])
    @users = @company.employees
    @conversation = current_company_admin.mailbox.conversations.find(params[:id])
    gon.candidates = @users
    gon.employees = @company.employees.map(&:mention_data)
    gon.admins_display = @admins.map(&:mention_data)
    gon.company_admins_display = @company.admins.map(&:mention_data)
    @conversation.mark_as_read(current_company_admin)
  end
  
  def mark_as_unread
    @conversation = current_company_admin.mailbox.conversations.find(params[:id])
    if @conversation.is_read?(current_company_admin) 
      @conversation.mark_as_unread(current_company_admin) 
    else
      @conversation.mark_as_read(current_company_admin)
    end
    @color = @conversation.is_read?(current_company_admin) ? "read" : "unread"
    @icon = @conversation.is_read?(current_company_admin) ? "<i class='fa fa-envelope'></i>".html_safe : "<i class='fa fa-envelope-o'></i>".html_safe
  end


  def new
    @admins = Admin.all
    @company_admins = @company.admins.real_users - [current_company_admin]
    @users = @company.users
    gon.candidates = @users.available
    gon.employees = @current_company.employees
    gon.admins_display = @admins.map(&:mention_data)
    gon.company_admins_display = @company_admins.map(&:mention_data)
  end

  def create
    recipients = Admin.where(id: params[:admin_ids]).to_a +
      CompanyAdmin.where(id: params[:company_admin_ids]).to_a +
      User.where(id: params[:user_ids]).to_a

    receipt   = current_company_admin.send_message(recipients, params[:body], params[:subject])
    if params[:redirect_to].present?
      redirect_to params[:redirect_to]
    else
      redirect_to company_conversation_path(receipt.conversation)
    end
  end
  
  private
  
  def set_company
    @company = current_company_admin.company
    
  end
  
  
end

