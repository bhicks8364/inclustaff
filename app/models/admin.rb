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
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  belongs_to :company
  belongs_to :agency
  has_many :events
  has_many :eventables, :through => :events
  # has_many :orders, :through => :company
  # has_many :jobs, :through => :orders
  # has_many :employees, :through => :jobs
  # has_many :shifts, :through => :company
  has_many :skills, :through => :orders
  has_many :recruiter_jobs, class_name: "Job", foreign_key: "recruiter_id"
  has_many :account_orders, class_name: "Order", foreign_key: "account_manager_id"
  
  scope :company_admins,   -> { where.not(company_id: nil)}
  scope :agency_admins,    -> { where(company_id: nil)}
  scope :account_managers, -> { where(role: "Account Manager")}
  scope :owners,           -> { where(role: "Owner")}
  scope :payroll_admins,   -> { where(role: "Payroll")}
  scope :hr,               -> { where(role: "HR")}
  scope :recruiters,       -> { where(role: "Recruiter")}
  scope :limited,          -> { where(role: "Limited Access")}
         
  before_validation :set_username
  
  validates_numericality_of :company_id, allow_nil: true
  validates_numericality_of :agency_id, allow_nil: true
    
  def name;             "#{first_name} #{last_name}"; end
  def to_s;             name; end
    
  def agency?;          agency_id? && company_id.nil?;  end
  def company?;         company_id?;  end
  def account_manager?; role == "Account Manager"; end
  def owner?;           role == "Owner";  end
  def payroll?;         role == "Payroll"; end
  def recruiter?;       role == "Recruiter";  end
  def hr?;              role == "HR"; end
  def limited?;         role == "Limited Access"; end
         
  def timesheets
    if recruiter?
      recruiter_jobs.flat_map { |c| c.timesheets }
    elsif account_manager?
      account_orders.flat_map { |c| c.timesheets }
    elsif company?
      Company.find(company_id).timesheets
    else
      Timesheet.all
    end
  end
  def jobs
    if recruiter?
      recruiter_jobs
    elsif account_manager?
    account_orders.flat_map { |c| c.jobs }
    else
      Job.all
    end
  end
 
  def current_billing
    if self.recruiter? && self.recruiter_jobs.any?
      recruiter_jobs.joins(:timesheets).map{ |t| t.timesheets
      .last_week.sum(:total_bill).to_s}
    elsif self.account_manager? && self.account_orders.any?
      account_orders.joins(:timesheets).map{ |t| t.timesheets
      .last_week.sum(:total_bill).to_s;}
    else
      0
    end
  end  
  def last_week_billing
    if self.recruiter? && self.recruiter_jobs.any?
      recruiter_jobs.joins(:current_timesheet).sum(:total_bill)
    elsif self.account_manager? && self.account_orders.any?
      account_orders.joins(:current_timesheets).sum(:total_bill)
    else 
      0
    end
  end
  def billing
    if self.recruiter? && self.recruiter_jobs.any?
      recruiter_jobs.joins(:timesheets).sum(:total_bill)
    elsif self.account_manager? && self.account_orders.any?
      account_orders.joins(:timesheets).sum(:total_bill)
    else
      0
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
    else 
      0
    end
  end
         
  def set_username
    self.username = name.gsub(/\s(.)/) {|e| $1.upcase}
  end
  
  def self.sorted_by_current_billing
    Admin.all.sort_by(&:current_billing).reverse!
  end
  def self.sorted_by_total_billing
    Admin.all.sort_by(&:billing).reverse!
  end
  def self.sorted_by_last_week_billing
    Admin.all.sort_by(&:last_week_billing).reverse!
  end    
         
   

end
