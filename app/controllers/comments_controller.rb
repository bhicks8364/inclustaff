class CommentsController < ApplicationController
  # before_action :authenticate_admin!
  layout :determine_layout
  def index
    @q = Comment.includes(:commentable).ransack(params[:q]) 
    if params[:q].present?
       @comments = @q.result(distinct: true).paginate(page: params[:page], per_page: 5)
    else
     @comments = Comment.none
    end
    
  end
  def search
    
  end
  def new
    @comment = Comment.new
  end
  def show
    @comment = Comment.find(params[:id])
  end
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
  def destroy
    @job = Job.find(params[:job_id]) if params[:job_id].present?
    @comment = Comment.find(params[:id])
    @comment.destroy
    
      respond_to do |format|
        # format.js
        format.html { redirect_to comments_path, notice: 'Comment was successfully destroyed.' }
        format.json { head :no_content }
      end
    
  end

  private

    def comment_params
      params.require(:comment).permit(:body, :commentable_id, :commentable_type, :admin_id, :company_admin_id, :user_id)
    end
  def determine_layout
    current_admin ? "admin_layout" : "application"
  end
end