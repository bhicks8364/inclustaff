# == Schema Information
#
# Table name: agencies
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  admin_id   :integer
#  subdomain  :string
#

class Agency < ActiveRecord::Base
    # belongs_to :admin
    has_many :invoices
    has_many :companies
    has_many :order_events, :through => :orders, :source => 'events'
    has_many :applications, :through => :orders, :source => 'events'
    has_many :applicants, :through => :applications, :source => 'users'
    has_many :admins
    has_many :events, :through => :admins
    has_many :users
    has_many :employees, :through => :jobs
    has_many :orders
    has_many :admin_events, :through => :admins, :source => 'events'
    has_many :jobs, :through => :orders
    has_many :current_timesheets, :through => :jobs
    has_many :timesheets, :through => :jobs
    has_many :shifts, :through => :timesheets
    has_many :owners, -> { where(role: 'Owner', company_id: nil) }, class_name: "Admin"
    has_many :recruiters, -> { where(role: 'Recruiter', company_id: nil) }, class_name: "Admin"
    has_many :payroll_admin,  -> { where(role: "Payroll", company_id: nil) }, class_name: "Admin"
    has_many :account_managers,  -> { where(role: "Account Manager", company_id: nil) }, class_name: "Admin"
    
    after_create :create_tenant
    
    
    
    # def agency_events
    #     Event.admin_events(self.id)
    # end
    validates :subdomain, exclusion: { in: %w(www us ca jp),
                        message: "%{value} is reserved." }
    
    accepts_nested_attributes_for :admins
    
    
    
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
    
  
    private
    def create_tenant
        Apartment::Tenant.create(subdomain)
    end
    
    
    
    
    
end
