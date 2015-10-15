# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  company_id             :integer
#  role                   :string
#  username               :string
#  agency_id              :integer
#

class Admin < ActiveRecord::Base
  belongs_to :company
  belongs_to :agency
  has_many :events
  has_many :eventables, :through => :events
  has_many :orders, :through => :company

  has_many :jobs, :through => :orders
  has_many :employees, :through => :jobs
  has_many :shifts, :through => :company
  has_many :skills, :through => :orders
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # before_save :set_username
  
  # validates :agency_id, presence: true, unless: ->(admin){admin.company_id.present?}
  # validates :company_id, presence: true, unless: ->(admin){admin.agency_id.present?}
  
    validates_numericality_of :company_id, allow_nil: true
    validates_numericality_of :agency_id, allow_nil: true


    # validate :company_xor_agency
    

  
         
         
  scope :account_managers, -> { where(role: "Account Manager")}
  scope :company_admins, -> { where.not(company_id: nil)}
  scope :agency_admins, -> { where(company_id: nil)}
  scope :owners, -> { where(role: "Owner")}
  scope :payroll_admins, -> { where(role: "Payroll")}
  scope :hr, -> { where(role: "HR")}
  scope :recruiters, -> { where(role: "Recruiter")}
  scope :limited, -> { where(role: "Limited Access")}
  
  
  
  def recruiter_jobs
    Job.by_recuriter(self.id) if self.recruiter?
  end
  # scope :top_recruiters, -> { recruiter_jobs.joins(:current_timesheet).
         
  def agency?
    if self.agency_id != nil
      true
    else
      false
    end
  end
  
  def company?
    if self.company_id != nil
      true
    else
      false
    end
  end
  
  def account_manager?
    if self.role == "Account Manager"
      true
    else
      false
    end
  end
  def owner?
    if self.role == "Owner"
      true
    else
      false
    end
  end
  def payroll?
    if self.role == "Payroll"
      true
    else
      false
    end
  end
  def recruiter?
    if self.role == "Recruiter"
      true
    else
      false
    end
  end
  def hr?
    if self.role == "HR"
      true
    else
      false
    end
  end
  def limited?
    if self.role == "Limited Access"
      true
    else
      false
    end
  end
         
  def name
    "#{first_name} #{last_name}"
  end
  def to_s
    name
  end
  
    # def manager_timesheets
  #   if self.manager?
  #     self.orders.collect { |a| a.book } 
  #   end
  # end  
  def account_orders
    Order.by_account_manager(self.id)
  end
  def personal_events
    Event.admin_events(self.id)
  end
  
  
  def recruiter_jobs
    Job.by_recuriter(self.id) if self.recruiter?
  end
  
  def current_billing
    if self.recruiter? && self.recruiter_jobs.any?
      recruiter_jobs.joins(:current_timesheet).sum(:total_bill)
    elsif self.account_manager? && self.account_orders.any?
      account_orders.joins(:current_timesheets).sum(:total_bill)
    end
  end  
  def billing
    if self.recruiter? && self.recruiter_jobs.any?
      recruiter_jobs.joins(:timesheets).sum(:total_bill)
    elsif self.account_manager? && self.account_orders.any?
      account_orders.joins(:timesheets).sum(:total_bill)
    end
  end
  
  def current_commission
    if self.recruiter? && self.recruiter_jobs.any?
      pay = recruiter_jobs.joins(:current_timesheet).sum(:gross_pay)
      bill = recruiter_jobs.joins(:current_timesheet).sum(:total_bill)
      (bill - pay) * 0.15  #FAKE COMMISSION RATE
    elsif self.account_manager? && self.account_orders.any?
      pay = account_orders.joins(:current_timesheets).sum(:gross_pay)
      bill = account_orders.joins(:current_timesheets).sum(:total_bill)
      (bill - pay) * 0.15  #FAKE COMMISSION RATE
    end
  end
         
    def set_username
      self.username = self.name.gsub(/\s(.)/) {|e| $1.upcase}
    end
         
         
    private

    def company_xor_agency
      if !(company_id.blank? ^ agency_id.blank?)
        errors.add(:base, "Specify a company or an agency, not both")
      end
    end     
         
         
         
         
         
end
