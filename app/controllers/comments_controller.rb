class CommentsController < ApplicationController
#   before_action :authenticate_user!

  def create
    @comment = Comment.new comment_params
    @comment.user = current_user if user_signed_in?
    @comment.admin = current_admin if admin_signed_in?
    @comment.company_admin = current_company_admin if company_admin_signed_in?
    @comment.save
    respond_to do |format|
      format.js 
      format.html { redirect_to :back, notice: 'Comment was successfully createed.' }
      format.json { head :no_content }
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:body, :commentable_id, :commentable_type, :admin_id, :company_admin_id, :user_id)
    end
end