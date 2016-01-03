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
#  name                   :string
#  latitude               :float
#  longitude              :float
#

class Admin < ActiveRecord::Base
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  geocoded_by :current_sign_in_ip
  after_validation :geocode
  
  belongs_to :agency
  has_many :events
  has_many :eventables, :through => :events
  has_many :comments
  has_many :recruiter_jobs, class_name: "Job", foreign_key: "recruiter_id"
  has_many :account_orders, class_name: "Order", foreign_key: "account_manager_id"

  scope :account_managers, -> { where(role: "Account Manager")}
  scope :owners,           -> { where(role: "Owner")}
  scope :payroll_admins,   -> { where(role: "Payroll")}
  scope :hr,               -> { where(role: "HR")}
  scope :recruiters,       -> { where(role: "Recruiter")}
  scope :limited,          -> { where(role: "Limited Access")}
         
  before_validation :set_name, :set_username
  validates :agency_id,  presence: true
  validates_numericality_of :agency_id, allow_nil: true
    
  def set_name;             self.name = "#{first_name} #{last_name}"; end
  def phone_number;             agency.phone_number; end
  def to_s;             name; end
  def name_role;             "#{name} #{role}"; end
  def agency?;          agency_id? && company_id.nil?;  end
  def company?;         company_id?;  end
  def account_manager?; role == "Account Manager"; end
  def owner?;           role == "Owner";  end
  def payroll?;         role == "Payroll"; end
  def recruiter?;       role == "Recruiter";  end
  def hr?;              role == "HR"; end
  def limited?;         role == "Limited Access"; end
  def admin?;         true; end
  def employee?;         false; end
  def mention_data; {name: "#{name}", content: "#{role}"}; end
  def online?
    updated_at > 10.minutes.ago
  end
  
  def timesheets
    if recruiter?
      Timesheet.by_recuriter(id)
    elsif account_manager?
      Timesheet.by_account_manager(id)
    else
      Timesheet.all
    end
  end
  
  def jobs
    if recruiter?
      recruiter_jobs
    elsif account_manager?
      Job.by_account_manager(id)
    else
      Job.all
    end
  end
  def job_orders
    if recruiter?
      Order.by_recuriter(id)
    elsif account_manager?
      account_orders
    else
      Order.all
    end
  end
  def companies
    if recruiter?
      Company.by_recuriter(id)
    elsif account_manager?
      Company.by_account_manager(id)
    else
      Company.all
    end
  end
  def messages
      Comment.by_recipient(id, "Admin")
  end
  
  def current_billing
    if timesheets.any?
      timesheets.current_week.sum(:total_bill)
    else
      0.00
    end
  end
  
  def last_week_billing
    if timesheets.any?
      timesheets.last_week.sum(:total_bill)
    else
      0.00
    end
  end
  
  def billing
    if timesheets.any?
      timesheets.sum(:total_bill)
    else
      0.00
    end
  end

  def billing_difference
    current_billing - last_week_billing
  end
  
  def current_commission
    if timesheets.current_week.any?
      pay = timesheets.current_week.sum(:gross_pay)
      bill = timesheets.current_week.sum(:total_bill)
      (bill - pay) * 0.15  #FAKE COMMISSION RATE
    else
      0.00
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
