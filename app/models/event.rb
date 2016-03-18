# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  admin_id         :integer
#  action           :string
#  eventable_id     :integer
#  eventable_type   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  agency_id        :integer
#  company_admin_id :integer
#  read_at          :datetime
#
# Indexes
#
#  index_events_on_agency_id         (agency_id)
#  index_events_on_company_admin_id  (company_admin_id)
#  index_events_on_user_id           (user_id)
#

class Event < ActiveRecord::Base
    belongs_to :admin
    belongs_to :company_admin
    belongs_to :user
    has_one :employee, through: :user
    belongs_to :eventable, polymorphic: true
    include ArelHelpers::ArelTable
    include Arel::Nodes
    
    validates_presence_of :eventable_id, :eventable_type, :action
    
    default_scope { order(created_at: :desc) } 
    scope :admin, -> { where.not(admin_id: nil)}
    scope :employee, -> { where.not(user_id: nil)}
    scope :company_admin, -> { where.not(company_admin_id: nil)}
  
    scope :applications, -> { where(action: 'applied').joins(:user).merge(User.available)}
    scope :follows, -> { where(action: 'followed')}
    scope :clock_ins, -> { where(action: 'clocked_in')}
    scope :timesheets, -> { where(eventable_type: 'Timesheet')}
    scope :jobs, -> { where(eventable_type: 'Job')}
    scope :comments, -> { where(action: 'commented')}
    scope :looking_for_work, -> { where(action: 'looking_for_work').joins(:user => :employee).merge(Employee.available)}
    scope :job_approvals, -> { where(action: 'approved', eventable_type: 'Job')}
    scope :assignment_ended, -> { where(action: 'assignment_ended', eventable_type: 'Job')}
    scope :job_rejections, -> { where(action: 'declined', eventable_type: 'Job')}
    scope :timesheet_approvals, -> { where(action: 'approved', eventable_type: 'Timesheet')}
    scope :clock_outs, -> { where(action: 'clocked_out')}
    scope :unread, -> { where(read_at: nil)}
    scope :read, -> { where.not(read_at: nil)}
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
    scope :past_2_weeks,  -> {
          start = Time.current.beginning_of_week - 7.days
          ending = start.end_of_week 
          where(created_at: start..ending)}
    def self.happened_before(date)
      where(Event[:created_at].lteq(date))
    end
    def self.happened_after(date)
      where(Event[:created_at].gteq(date))
    end
    def self.occurring_between(date1, date2)
      where(Event[:created_at].gteq(date1)
      .and(Event[:created_at].lteq(date2)))
    end
    
    def unread?;    read_at == nil;    end
    def read?;  !unread?;    end
    def state;  unread? ? "Unread" : "Read";    end
    def declined?; action == "declined";  end
    def follow?; action == "followed";  end
    def application?; action == "applied";  end
    def timesheet?; eventable_type == "Timesheet";  end
    def job?;   eventable_type == "Job";    end
    def admin?;   eventable_type == "Admin";    end
    def company_admin?;   eventable_type == "CompanyAdmin";    end
    def user?;   eventable_type == "User";    end
    def shift?;   eventable_type == "Shift";    end
        
    def self.following_admin
        where(action: "followed", eventable_type: "Admin")
    end
    def self.following_company_admin
        where(action: "followed", eventable_type: "CompanyAdmin")
    end
    def self.following_candidates
        where(action: "followed", eventable_type: "User")
    end
    def self.mentions(admin_id)
        where(action: "mentioned", eventable_id: admin_id)
    end
    
    
    def self.employee_events(user_id)
        where(eventable_id: user_id)
    end
    def self.admin_events(admin_id)
        where(eventable_id: admin_id)
    end
    def self.without_eventable
        timesheet_approvals.joins(:timesheets).where( :timesheets => { :id => nil } )
    end
    
end
