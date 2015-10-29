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
    has_many :invoices
    has_many :orders, dependent: :destroy
    has_many :order_events, :through => :orders, :source => 'events'
    has_many :jobs, :through => :orders
    has_many :employees, :through => :jobs
    has_many :shifts, :through => :jobs
    has_many :timesheets, :through => :jobs
    has_many :current_timesheets, :through => :jobs
    has_many :account_managers, :through => :orders
    has_many :recruiters, :through => :jobs
    has_many :admins
    has_many :admin_events, :through => :admins, :source => 'events'
    # has_one :owner, -> { where role: 'Owner' }, class_name: "Admin"
    # has_many :recruiters, -> { where role: 'Recruiter' }, class_name: "Admin"
    # has_many :payroll_admin,  -> { where role: "Payroll" }, class_name: "Admin"
    # has_many :account_managers,  -> { where role: "Account Manager" }, class_name: "Admin"
    scope :with_open_orders, -> { joins(:orders).merge(Order.needs_attention)} 
    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.current_week)}
    scope :ordered_by_current_bill, -> { includes(:current_timesheets).order('timesheets.total_bill') }
    accepts_nested_attributes_for :orders
    
    include ArelHelpers::ArelTable
    include ArelHelpers::JoinAssociation
    
    def to_s; name; end
    
    def current_agency
      if orders.any?
          orders.last.agency
      end
    end
    
    def current_account_manager
      if orders.any? && orders.last.account_manager.present?
         orders.last.account_manager
      elsif orders.any? && agency.account_managers.any?
        agency.account_managers.last
      else
        agency.owners.first
      end
    end
    
    
    
   
    


    
    validates :name,  presence: true, length: { maximum: 50 }
    validates :contact_name,  presence: true, length: { maximum: 20 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :contact_email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

 
    def current_payroll_cost
       timesheets.current_week.sum(:gross_pay)
    end
    def current_billing
       timesheets.current_week.sum(:total_bill)
    end
    def last_week_billing
        timesheets.last_week.sum(:total_bill)
    end

    
    def set_payroll_cost!
        cost = timesheets.current_week.sum(:total_bill)
        update(balance: cost)
    end
    
    # IMPORT TO CSV
    def self.assign_from_row(row)
        company = Company.where(name: row[:name]).first_or_initialize
        company.assign_attributes row.to_hash.slice(:name, :address, :city, :state, :zipcode, :contact_name, :contact_email, :admin_id, :agency_id, :phone_number)
        company
    end
    
    # EXPORT TO CSV
    def self.to_csv
      attributes = %w{id name address city state contact_name contact_email balance phone_number admin_id agency_id}
      CSV.generate(headers: true) do |csv|
        csv << attributes
        
        all.each do |company|
          csv << attributes.map{ |attr| company.send(attr) }
        end
      end
    end
    
end
