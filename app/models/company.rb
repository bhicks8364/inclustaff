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
#  user_id       :integer
#  agency_id     :integer
#  admin_id      :integer
#

class Company < ActiveRecord::Base
    default_scope { order(name: 'DESC') }
    belongs_to :agency
    has_many :orders, dependent: :destroy
    
    has_many :jobs, :through => :orders
    has_many :employees, :through => :jobs
    has_many :shifts, :through => :jobs
    has_many :timesheets, :through => :jobs
    has_many :current_timesheets, :through => :jobs
    has_many :account_managers, :through => :orders
    has_many :recruiters, :through => :jobs
    has_many :admins
    has_many :events, :through => :admins
    has_one :owner, -> { where role: 'Owner' }, class_name: "Admin"
    # has_many :recruiters, -> { where role: 'Recruiter' }, class_name: "Admin"
    # has_many :payroll_admin,  -> { where role: "Payroll" }, class_name: "Admin"
    # has_many :account_managers,  -> { where role: "Account Manager" }, class_name: "Admin"
    
    accepts_nested_attributes_for :orders
    
    include ArelHelpers::ArelTable
    include ArelHelpers::JoinAssociation
    
    def to_s
        name
    end
    
    def current_agency
        if self.orders.any?
            self.orders.last.agency
        end
    end
    
    def current_account_manager
        if self.orders.any?
            self.orders.last.agency
        end
    end
    
    
    
   
    


    
    validates :name,  presence: true, length: { maximum: 50 }
    # validates :contact_name,  presence: true, length: { maximum: 20 }
    # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    # validates :contact_email, presence: true, length: { maximum: 255 },
    #                 format: { with: VALID_EMAIL_REGEX },
    #                 uniqueness: { case_sensitive: false }

    
    # def total_hours
    #   self.
    # end

    #   self.owner = User.find_or_create_by(email: self.contact_email, last_name: last_name, 
    #                                 first_name: first_name, encrypted_password: generated_password,
    #                                 company_id: self.id, role: "Admin")
    # end
    
    def current_payroll_cost
        self.timesheets.current_week.sum(:gross_pay)
    end
    def current_billing
        self.timesheets.current_week.sum(:total_bill)
    end
    def last_week_billing
        self.timesheets.last_week.sum(:total_bill)
    end

    
    def set_payroll_cost!
        cost = self.timesheets.approved.sum(:total_bill)
        self.update(balance: cost)
    end
    
    
    
    # c.shifts.current_week.sum(:time_worked)
    
    
    
    
end
