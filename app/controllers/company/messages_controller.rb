class Company::MessagesController < ApplicationController
  before_action :skip_authorization
  before_action :set_conversation

  def create
    receipt = current_company_admin.reply_to_conversation(@conversation, params[:body])
    redirect_to company_conversation_path(receipt.conversation)
  end

  private

    def set_conversation
      @conversation = current_company_admin.mailbox.conversations.find(params[:conversation_id])
    end
end

