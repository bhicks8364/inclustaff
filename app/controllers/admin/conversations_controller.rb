class Admin::ConversationsController < ApplicationController
  before_action :skip_authorization

  layout 'admin_layout'

  def index
    @conversations = current_admin.mailbox.conversations
    @sent_box = current_admin.mailbox.sentbox
  end

  def show
    @conversation = current_admin.mailbox.conversations.find(params[:id])
  end

  def new
    @admins = Admin.all - [current_admin]
    @company_admins = CompanyAdmin.real_users
    @users = User.all
    gon.candidates = @users.available
    gon.employees = @users.assigned
    gon.admins_display = @admins.map(&:mention_data) + @company_admins.map(&:mention_data)
    gon.company_admins_display = @company_admins.map(&:mention_data)
  end

  def create
    recipients = Admin.where(id: params[:admin_ids]).to_a +
      CompanyAdmin.where(id: params[:company_admin_ids]).to_a +
      User.where(id: params[:user_ids]).to_a

    receipt   = current_admin.send_message(recipients, params[:body], params[:subject])
    if params[:redirect_to].present?
      redirect_to params[:redirect_to]
    else
      redirect_to admin_conversation_path(receipt.conversation)
    end
  end
end
