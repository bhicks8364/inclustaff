# == Schema Information
#
# Table name: agencies
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Agency < ActiveRecord::Base
    has_many :admins
    has_many :events, :through => :admins
    has_many :users
    has_many :employees, :through => :jobs
    has_many :orders
    has_many :companies, :through => :orders
    has_many :jobs, :through => :orders
    has_many :timesheets, :through => :jobs
    has_many :shifts, :through => :timesheets
    has_many :owners, -> { where(role: 'Owner', company_id: nil) }, class_name: "Admin"
    has_many :recruiters, -> { where(role: 'Recruiter', company_id: nil) }, class_name: "Admin"
    has_many :payroll_admin,  -> { where(role: "Payroll", company_id: nil) }, class_name: "Admin"
    has_many :account_managers,  -> { where(role: "Account Manager", company_id: nil) }, class_name: "Admin"
    
    # def agency_events
    #     Event.admin_events(self.id)
    # end
    
    def current_billing
        self.timesheets.current_week.sum(:total_bill)
    end
    def current_payroll
        self.timesheets.current_week.sum(:gross_pay)
    end
    
    def current_revenue
        (current_billing - current_payroll).round(2)
    end
    
    def last_week_billing
        self.timesheets.last_week.sum(:total_bill)
    end
        
    
    
    
end
