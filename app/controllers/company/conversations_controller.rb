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

  def show
    @users = @company.employees
    @conversation = current_company_admin.mailbox.conversations.find(params[:id])
    gon.candidates = @users
    gon.employees = @company.employees.map(&:mention_data)
    gon.admins_display = @admins.map(&:mention_data)
    gon.company_admins_display = @company.admins.map(&:mention_data)
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

