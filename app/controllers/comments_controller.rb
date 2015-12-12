class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy, :mark_as_read]
  before_action :skip
  layout :determine_layout
  def index
    @q = Comment.includes(:commentable).ransack(params[:q]) 
    # if params[:q].present?
    #   @comments = @q.result(distinct: true).paginate(page: params[:page], per_page: 5)
    # else
      @comments = Comment.all
    # end
    gon.comments = Comment.unread
    # @notifications = Comment.where(recipient: current_user).unread
    # @notifications = Comment.where(recipient: @signed_in).unread
    
    
  end
        
  def search
    index
    render :index
  end
  def new
    @comment = Comment.new
  end
  def show
    gon.comment = @comment
    gon.commentable = @comment.commentable
  end
  def create
    @comment = Comment.new comment_params
   
    @comment.user = current_user if user_signed_in?
    @comment.admin = current_admin if admin_signed_in?
    @comment.company_admin = current_company_admin if company_admin_signed_in?
    @comment.save
        
    
    respond_to do |format|
     
      format.js 
      format.html { redirect_to :back, notice: 'Comment was successfully created.' }
      format.json { head :no_content }

    end
    
  end
  def edit
    
    
  end
  def update
    # @recipient_type = params[:recipient_type]
    
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: "Comment was successfully sent to: "+ "#{@recipient_type}" }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
 
  end
  
  def mark_as_read
    if @comment.unread?
      @comment.update(read_at: Time.current)
    else
      @comment.update(read_at: nil)
    end
    @new_count = Comment.unread.count
    render json: { id: @comment.id, read: @comment.read?, new_count: @new_count,
                    body: @comment.body, commentable: @comment.commentable, state: @comment.state}
  end
  def mark_all_read
    @comments = Comment.unread
    @comments.update_all(read_at: Time.zone.now)
    render json: {success: true}
  end
  
  def destroy
    @job = Job.find(params[:job_id]) if params[:job_id].present?
    
    @comment.destroy
    
      respond_to do |format|
        # format.js
        format.html { redirect_to comments_path, notice: 'Comment was successfully destroyed.' }
        format.json { head :no_content }
      end
    
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
      name = @comment.recipient.try(:name) || "Nobody"
      gon.push({
        :commentable_id => @comment.commentable_id,
        :commentable_type => @comment.commentable_type,
        :recipient_id => @comment.recipient_id,
        :recipient_name => name,
        :recipient_type => @comment.recipient_type
      })
    end
    def skip
      skip_authorization
    end
    def comment_params
      params.require(:comment).permit(:body, :commentable_id, :commentable_type, :admin_id, :read_at, :company_admin_id, :user_id, :recipient_id, :recipient_type)
    end
  def determine_layout
    current_admin ? "admin_layout" : "application"
  end
end