# == Schema Information
#
# Table name: public.agencies
#
#  id            :integer          not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_id      :integer
#  subdomain     :string
#  address       :string
#  city          :string
#  state         :string
#  zipcode       :string
#  phone_number  :string
#  free_trial    :boolean
#  contact_name  :string
#  contact_email :string
#  contact_id    :integer
#  logo_url      :string
#  preferences   :hstore           default({})
#

class Agency < ActiveRecord::Base
  # has_many :current_timesheets, :through => :jobs
  # has_many :shifts, :through => :timesheets
  # has_many :timesheets, :through => :jobs
  belongs_to :contact, class_name: "Admin"
  has_many :account_managers,  -> { where(role: "Account Manager", company_id: nil) }, class_name: "Admin"
  has_many :admin_events, :through => :admins, :source => 'events'
  has_many :admins
  has_many :agency_admins, -> { where(company_id: nil) }, class_name: "Admin"
  has_many :applicants, :through => :applications, :source => 'users'
  has_many :applications, :through => :orders, :source => 'events'
  has_many :companies
  has_many :company_admins, :through => :companies, :source => 'admins'
  has_many :employees, :through => :users
  has_many :events, :through => :admins
  has_many :invoices
  has_many :job_comments, through: :jobs, source: 'comments'
  has_many :jobs, :through => :orders
  has_many :jobs, :through => :orders
  has_many :order_events, :through => :orders, :source => 'events'
  has_many :orders
  has_many :owners, -> { where(role: 'Owner', company_id: nil) }, class_name: "Admin"
  has_many :payroll_admin,  -> { where(role: "Payroll", company_id: nil) }, class_name: "Admin"
  has_many :recruiters, -> { where(role: 'Recruiter', company_id: nil) }, class_name: "Admin"
  has_many :shift_comments, through: :shifts, source: 'comments'
  has_many :timesheet_comments, through: :timesheets, source: 'comments'
  has_many :users

  store_accessor :preferences, :aca_measurement_period, :aca_administrative_period, :aca_stability_period, :weekly_sales_goal

  accepts_nested_attributes_for :admins

  after_create :create_tenant

  validates :subdomain, :format => { :with => /\A[a-zA-Z]+\z/, :message => "Only letters allowed" }
  validates :subdomain, exclusion: { in: %w(www us ca jp public admin inclustaff), message: "%{value} is reserved." }
  validates :name,  presence: true, length: { maximum: 50 }
  validates :subdomain, uniqueness: true

  before_validation :set_stability_period

  def demo?
    subdomain == "demo"
  end

  def set_stability_period
    self.preferences = self.preferences.merge({aca_stability_period: self.aca_measurement_period})
  end

  def weekly_sales_goal
    preferences['weekly_sales_goal'].present? ? preferences['weekly_sales_goal'].to_i : 0
  end

  def percent_to_sales_goal
    current_billing / weekly_sales_goal * 100
  end

  def shifts
    Shift.order(updated_at: :desc)
  end

  def timesheets
    Timesheet.order(week: :desc)
  end

  def current_timesheets
    Timesheet.current_week.order(week: :desc)
  end

  def current_billing
    timesheets.current_week.sum(:total_bill)
  end

  def current_payroll
    timesheets.current_week.sum(:gross_pay)
  end

  def current_revenue
    (current_billing - current_payroll).round(2)
  end

  def last_week_billing
    timesheets.last_week.sum(:total_bill)
  end

  def billable_users
    admins.current_week.count + company_admins.current_week.count + timesheets.current_week.count
  end

  private

    def create_tenant
      Apartment::Tenant.create(subdomain)
    end

    # Apartment::Tenant.switch!('gtrjobs')
    # Apartment::Tenant.switch!('demo')
end
