# == Schema Information
#
# Table name: companies
#
#  id            :integer          not null, primary key
#  name          :string
#  address       :string
#  state         :string
#  zipcode       :string
#  contact_name  :string
#  contact_email :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  city          :string
#  balance       :decimal(, )
#  phone_number  :string
#

class Company < ActiveRecord::Base
    has_many :orders
    has_many :jobs, :through => :orders
    has_many :employees, :through => :jobs
    has_many :shifts, :through => :jobs
    has_many :timesheets, :through => :jobs
    has_many :users
    has_many :company_users, -> { where.not(role: "Employee")}, class_name: "User"
    has_many :employee_users,  -> { where role: "Employee" }, class_name: "User"
    has_many :payroll_users,  -> { where role: "Payroll" }, class_name: "User"
    has_many :admin_users,  -> { where role: "Admin" }, class_name: "User"
    has_many :manager_users,  -> { where role: "Manager" }, class_name: "User"
    
    validates :name,  presence: true, length: { maximum: 50 }
    validates :contact_name,  presence: true, length: { maximum: 20 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :contact_email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    

    # def total_hours
    #   self.
    # end
    
    def current_payroll_cost
        self.timesheets.this_week.sum(:gross_pay)
    end
    
    
    # c.shifts.current_week.sum(:time_worked)
    
    
    
    
end
