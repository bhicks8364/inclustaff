# == Schema Information
#
# Table name: timesheets
#
#  id               :integer          not null, primary key
#  job_id           :integer
#  reg_hours        :decimal(, )
#  ot_hours         :decimal(, )
#  gross_pay        :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  state            :string
#  approved_by      :integer
#  shifts_count     :integer
#  total_bill       :decimal(, )
#  invoice_id       :integer
#  approved_by_type :string
#  total_hours      :decimal(, )
#  week             :date
#  reg_bill_rate    :decimal(, )
#  ot_bill_rate     :decimal(, )
#  week_ending      :date
#
# Indexes
#
#  index_timesheets_on_approved_by_type  (approved_by_type)
#  index_timesheets_on_deleted_at        (deleted_at)
#  index_timesheets_on_invoice_id        (invoice_id)
#  index_timesheets_on_job_id            (job_id)
#

class Timesheet < ActiveRecord::Base
  belongs_to :job, counter_cache: true
  belongs_to :invoice
  has_many :shifts, dependent: :destroy
  has_one :employee, :through => :job
  has_one :company, :through => :job
  has_one :order, :through => :job
  has_many :comments, as: :commentable
  has_many :events, as: :eventable
  has_one :recruiter, through: :job, class_name: "Admin"
  has_many :adjustments
  include ArelHelpers::ArelTable
  validates :job_id, uniqueness: { scope: :week,
    message: "should have only one timesheet per week" }
  accepts_nested_attributes_for :shifts, reject_if: :all_blank, allow_destroy: true
  validates :week, :job_id, presence: true
  # validates_associated :shifts
  delegate :name_title, :pay_rate, :ot_rate, :agency, :company, :manager, :recruiter, :current_shift, :account_manager, :order_id, to: :job
  delegate :ssn, to: :employee

  before_validation :total_timesheet, if: :clocked_out?
  after_initialize :defaults
  
  after_save :update_company_balance!, if: :total_bill_changed?
  # before_create :set_job, unless: :has_a_job?
  before_save :set_total_hours, :set_bill_rates, :calculate_billing
  # I dont think setting the invoice has to happen before_save. Maybe just before create?
  before_save :set_invoice, unless: :has_invoice?
  after_save :update_invoice!, if: :has_invoice?

  def has_a_job?
    job_id.present?
  end
  def has_invoice?
    invoice.present?
  end
  def self.by_recruiter(admin_id)
    joins(:job).where(jobs: { recruiter_id: admin_id })
  end

  scope :with_recent_comments,    -> { joins(:comments).merge(Comment.timesheet_comments.payroll_week)}
  scope :with_job, -> { includes(:job)}
  scope :with_shift_notes,    -> { joins(:shifts).merge(Shift.with_notes)}
  scope :approved, -> { where(state: "approved")}
  scope :pending, -> { where(state: "pending")}
  scope :this_year,    -> { joins(:shifts).merge(Shift.this_year)}
  scope :last_week,    -> { joins(:shifts).merge(Shift.last_week)}
  scope :approaching_overtime, -> { where('reg_hours > 36') }
  scope :current_week, ->{ where(week: Time.current.to_date.beginning_of_week)}
  scope :past, -> { joins(:shifts).merge(Shift.past) }
  scope :over_50, -> { where(Timesheet[:total_hours].gteq(50))}
  scope :overtime_errors, -> { where('reg_hours > 40') }
  scope :needing_approval, -> { last_week.pending }
  def self.worked_before(date)
    includes(:shifts).where(Shift[:time_in].lteq(date))
  end
  def self.worked_after(date)
    includes(:shifts).where(Shift[:time_in].gteq(date))
  end
  def self.occurring_between(date1, date2)
    where(Shift[:time_in].gteq(date1)
      .and(Shift[:time_in].lteq(date2)))
  end
  def self.for_the_week_of(date=Time.current.to_date)
    where(Timesheet[:week].eq(date.beginning_of_week))
  end
  def receipt
    
    TimesheetPdf.new(
      id: id,
      message: "Weekly Pay Summary",
      company: {
        name: "#{company.agency.name}",
        address: "8364 Oberlin Rd\nElyria, OH 44035",
        email: "contact@inclustaff.com",
        logo: Rails.root.join("app/assets/images/clock.png")
      },

      line_items: [
        ["Week Ending",           week_ending],
        ["Assignment", "#{job.id} (#{job.title})"],
        ["Reg Hrs",        "#{reg_hours}    ($#{pay_rate.round(2)})"],
        ["OT Hrs",       "#{ot_hours}    ($#{ot_rate.round(2)})"],
        ["Gross Pay",         "$#{gross_pay.round(2)}"],

        ["Payroll ID", "#{id} - #{week}"]
      ]
    )
  end

  def name
    employee.name
  end

  def bill_to
    company.owner
  end

  def self.by_total_bill
    order(:total_bill)
  end
  # There should never be a timesheet without shifts. Need to fix this.
  def self.without_shifts
    includes(:shifts).where( :shifts => { :timesheet_id => nil } )
  end
  def self.by_account_manager(admin_id)
    joins(:job => :order).where( :orders => { :account_manager_id => admin_id } )
  end

  def set_invoice
    company_id = company.id
    agency_id = company.agency.id
    self.invoice = Invoice.find_or_create_by(agency_id: agency_id, company_id: company_id, week: week)
  end

  def approved?; state == "approved"; end
  def pending?; state == "pending"; end

  def defaults
    self.state = "pending" if state.nil?
    self.week = week.beginning_of_week if week.present?
    self.week_ending = week.end_of_week if week.present?
    self.reg_hours = 0 if reg_hours.nil?
    self.ot_hours = 0 if ot_hours.nil?
    self.gross_pay = 0 if gross_pay.nil?
    
  end
  def set_bill_rates
 
    self.reg_bill_rate = job.mark_up if reg_bill_rate.nil?
    self.ot_bill_rate = job.mark_up if ot_bill_rate.nil?
  end
  
  
  
  def calculate_billing
    reg_billing = job.pay_rate * reg_hours * reg_bill_rate
    ot_billing = job.pay_rate * ot_hours * ot_bill_rate
    self.total_bill = reg_billing + ot_billing
  end

  def set_total_hours
    if reg_hours && ot_hours
      self.total_hours = reg_hours + ot_hours
    elsif reg_hours
      self.total_hours = reg_hours
    end
  end

  def update_company_balance!
    company.set_payroll_cost!
  end

  def update_invoice!
    invoice.update_totals!
  end

  def last_clock_in
    if shifts.any?
      shifts.last.time_in
    end
  end

  def last_clock_out
    if shifts.any?
      shifts.last.time_out
    end
  end
  
  def user_approved
    if approved? && approved_by_type == "Admin"
      Admin.find(approved_by).name
    elsif approved? && approved_by_type == "CompanyAdmin"
      CompanyAdmin.find(approved_by).name
    else
      state
    end
  end
  

  # EXPORT TO CSV
  def self.to_csv
    attributes = %w{id order_id week_ending company employee_name ssn reg_hours ot_hours total_hours pay_rate ot_rate gross_pay state user_approved approved_by_type shifts_count invoice_id}
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |timesheet|
        csv << attributes.map{ |attr| timesheet.send(attr) }
      end
    end
  end

  def current?
     week == Date.today.beginning_of_week
  end
  def last_week?
     week == (Date.today.beginning_of_week - 1.week )
  end

  def company_order
    "#{company.name}" "#{order.title}"
  end

  def job_title
    job.title
  end

  def employee_name
    employee.name
  end

  def clocked_in?
    if shifts.clocked_in.any?
      true
    else
      false
    end
  end
  def clocked_out?
    if shifts.clocked_in.any?
      false
    else
      true
    end
  end

  def last_clocked_in
    shifts.last.time_in
  end

  def last_clocked_out
    shifts.clocked_out.last.time_out
  end

  def mark_up_percent
    (mark_up * 100 - 100).to_i.to_s + "%"
  end

  def total_timesheet
      if shifts.any?
      hours = shifts.sum(:time_worked)
      else
        hours = reg_hours + ot_hours
      end
      if hours > 40
        self.total_hours = hours
        self.reg_hours = 40
        self.ot_hours = hours - 40
        ot_rate = job.pay_rate * 1.5
        if adjustments.none?
          self.gross_pay = job.pay_rate * self.reg_hours + self.ot_hours * ot_rate
        end
      else
        self.total_hours = hours
        pay = job.pay_rate * hours
        self.reg_hours = hours
        self.ot_hours = 0
        if adjustments.none?
          self.gross_pay = pay
        end
      end
  end
  
  
  

  

  def week_begin
    week.stamp("1/22/2016")
  end

  def time_frame
    "#{week_begin} - #{week_ending.stamp("1/22/2016")}"
  end
  def employee_bill
    bill = total_bill || 0
    "#{employee_name} - $#{bill.round(2)}"
  end
  
end
