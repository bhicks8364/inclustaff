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

class Event < ActiveRecord::Base
    belongs_to :admin
    belongs_to :company_admin
    belongs_to :user
    belongs_to :eventable, polymorphic: true
    include ArelHelpers::ArelTable
    include Arel::Nodes
    scope :admin, -> { where.not(admin_id: nil)}
    scope :employee, -> { where.not(user_id: nil)}
    scope :company_admin, -> { where.not(company_admin_id: nil)}
  
    scope :applications, -> { where(action: 'applied').joins(:user).merge(User.available)}
    scope :follows, -> { where(action: 'followed')}
    scope :clock_ins, -> { where(action: 'clocked_in')}
    scope :timesheets, -> { where(eventable_type: 'Timesheet')}
    scope :jobs, -> { where(eventable_type: 'Job')}
    scope :comments, -> { where(action: 'commented')}
    scope :approvals, -> { where(action: 'approved')}
    scope :clock_outs, -> { where(action: 'clocked_out')}
    scope :unread, -> { where(read_at: nil)}
    scope :read, -> { where.not(read_at: nil)}
    
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
    def application?
        if self.action == "applied"
            true
        else
            false
        end
    end
    def timesheet?
        if eventable_type == "Timesheet"
            true
        else
            false
        end
    end
    def unread?
      read_at == nil
    end
    def read?
      !unread?
    end
    def state
      unread? ? "Unread" : "Read"
    end
    def job?
        if eventable_type == "Job"
            true
        else
            false
        end
    end
    
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
    
    
end
