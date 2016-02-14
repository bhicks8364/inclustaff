# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string
#  commentable_id   :integer
#  admin_id         :integer
#  company_admin_id :integer
#  user_id          :integer
#  body             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  action           :string
#  recipient_id     :integer
#  recipient_type   :string
#  alert            :boolean
#  read_at          :datetime
#  notify           :hstore           default({})
#
# Indexes
#
#  index_comments_on_action            (action)
#  index_comments_on_admin_id          (admin_id)
#  index_comments_on_commentable_id    (commentable_id)
#  index_comments_on_commentable_type  (commentable_type)
#  index_comments_on_company_admin_id  (company_admin_id)
#  index_comments_on_recipient_id      (recipient_id)
#  index_comments_on_recipient_type    (recipient_type)
#  index_comments_on_user_id           (user_id)
#

class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy, :mark_as_read]
  # before_action :authenticate_admin!
  layout :determine_layout
  def index
    @comments = Comment.all if admin_signed_in?
    @comments = @current_company.job_comments.all if company_admin_signed_in?
    @q = Comment.includes(:commentable).ransack(params[:q]) 
    if params[:q].present?
      @comments = @q.result(distinct: true).paginate(page: params[:page], per_page: 5)
    end
    gon.comments = Comment.unread
    skip_authorization
    # @notifications = Comment.where(recipient: current_user).unread
    # @notifications = Comment.where(recipient: @signed_in).unread
    
    
  end
        
  def search
    index
    render :index
  end
  def new
    @comment = Comment.new
    skip_authorization
  end
  def show
    gon.comment = @comment
    gon.commentable = @comment.commentable
    skip_authorization
  end
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user if user_signed_in?
    @comment.admin = current_admin if admin_signed_in?
    @comment.company_admin = current_company_admin if company_admin_signed_in?
    skip_authorization
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end

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
                    skip_authorization
  end
  def mark_all_read
    @comments = Comment.unread
    @comments.update_all(read_at: Time.zone.now)
    skip_authorization
    render json: {success: true}
  end
  
  def destroy
    
    @comment.destroy
    
      respond_to do |format|
        format.js
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
      skip_authorization
    end
    def skip
      skip_authorization
    end
    def comment_params
      params.require(:comment).permit(:body, :commentable_id, :commentable_type, :admin_id, :read_at, :company_admin_id, :user_id, :recipient_id, :recipient_type, :account_manager, :recruiter)
    end
    def determine_layout
      if admin_signed_in?
        "admin_layout"
      elsif company_admin_signed_in?
        "company_layout"
      elsif user_signed_in?
        "employee"
      else
          "application"
      end
    end
end
