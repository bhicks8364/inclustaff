class Company::ConversationsController < ApplicationController
  before_action :skip_authorization

  layout 'company_layout'

  def index
    @conversations = current_company_admin.mailbox.conversations
  end

  def show
    @conversation = current_company_admin.mailbox.conversations.find(params[:id])
  end

  def new
    @admins = Admin.all
    @company_admins = CompanyAdmin.real_users - [current_company_admin]
    @users = User.all
  end

  def create
    recipients = Admin.where(id: params[:admin_ids]).to_a +
      CompanyAdmin.where(id: params[:company_admin_ids]).to_a +
      User.where(id: params[:user_ids]).to_a

    receipt   = current_company_admin.send_message(recipients, params[:body], params[:subject])
    redirect_to company_conversation_path(receipt.conversation)
  end
end

