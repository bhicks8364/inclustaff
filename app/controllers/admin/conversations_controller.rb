class Admin::ConversationsController < ApplicationController
  before_action :skip_authorization

  layout 'admin_layout'

  def index
    @conversations = current_admin.mailbox.inbox
  end
  
  def inbox
    @conversations = current_admin.mailbox.inbox.unread(current_admin)
    render action: :index
  end

  def sent
    @conversations = current_admin.mailbox.sentbox
    render action: :index
  end

  def trash
    @conversations = current_admin.mailbox.trash
    render action: :index
  end

  def show
    @conversation = current_admin.mailbox.conversations.find(params[:id])
    @conversation.mark_as_read(current_admin)
  end
  
  def mark_as_unread
    @conversation = current_admin.mailbox.inbox.find(params[:id])
    if @conversation.is_read?(current_admin) 
      @conversation.mark_as_unread(current_admin) 
    else
      @conversation.mark_as_read(current_admin)
    end
    @color = @conversation.is_read?(current_admin) ? "read" : "unread"
    @icon = @conversation.is_read?(current_admin) ? "<i class='fa fa-envelope'></i>".html_safe : "<i class='fa fa-envelope-o'></i>".html_safe
  end

  def new
    @admins = Admin.all - [current_admin]
    @company_admins = CompanyAdmin.real_users
    @users = User.all
    gon.candidates = @users.available
    gon.employees = @users.assigned
    # THis isn't working. Only pulling Agency Admins
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
