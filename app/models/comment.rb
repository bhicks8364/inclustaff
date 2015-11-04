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
#

class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
    belongs_to :recipient, polymorphic: true
    belongs_to :user
    belongs_to :admin
    belongs_to :company_admin
    scope :job_comments, -> { where(commentable_type: "Job")}
    scope :timesheet_comments, -> { where(commentable_type: "Timesheet")}
    scope :order_comments, -> { where(commentable_type: "Order")}
    scope :user_comments, -> { where(commentable_type: "User")}
    scope :by_company_admins, -> { where.not(company_admin_id: nil)}
    scope :by_agency_admins, -> { where.not(admin_id: nil)}
    scope :by_employees, -> { where.not(user_id: nil)}
    scope :payroll_week,  -> {
          start = Time.current.beginning_of_week
          ending = start.end_of_week + 7.days
          where(created_at: start..ending)}
    scope :current_week, -> {
          start = Time.current.beginning_of_week
          ending = start.end_of_week
          where(created_at: start..ending)}
    scope :today, -> {
          start = Date.today.beginning_of_day
          ending = Date.today.end_of_day
          where(created_at: start..ending)}
    scope :yesterday, -> {
          start = Date.yesterday.beginning_of_day
          ending = Date.today.beginning_of_day
          where(created_at: start..ending)}
    
end
