# == Schema Information
#
# Table name: employees
#
#  id           :integer          not null, primary key
#  first_name   :string
#  last_name    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  email        :string
#  ssn          :string
#  phone_number :string
#  user_id      :integer
#  deleted_at   :datetime
#  assigned     :boolean
#  resume_id    :string
#

class Employee < ActiveRecord::Base
  acts_as_paranoid
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  
  belongs_to :user
  has_many :skills, as: :skillable
  attachment :resume, extension: ["pdf", "doc", "docx"]
  has_many :shifts, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :orders, :through => :jobs
  has_many :companies, :through => :orders
  has_one :current_job, -> { where active: true }, class_name: "Job"
  has_one :current_shift, -> { where state: 'Clocked In' }, class_name: "Shift"
  has_many :timesheets, :through => :jobs



  accepts_nested_attributes_for :jobs
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true
  
  delegate :last_clock_out, to: :current_job
  delegate :title, to: :current_job
  delegate :manager, to: :current_job
  delegate :recruiter, to: :current_job
  delegate :code, to: :user
  delegate :current_sign_in_ip, to: :user
  delegate :email, to: :user
  # before_save :set_user_info
  before_validation :check_if_assigned
  
  def name_title
    if current_job.nil?
      "#{first_name} #{last_name} - Unassigned"
    else
      current_job.name_title
    end
  end

  
  # VALIDATIONS
  # validates :first_name,  presence: true, length: { maximum: 20 }
  # validates :last_name,  presence: true, length: { maximum: 20 }
  # validates :user_id, presence: true
  # validates :ssn, length: { is: 4 }
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # validates :email, presence: true, length: { maximum: 255 },
  #                 format: { with: VALID_EMAIL_REGEX },
  #                 uniqueness: { case_sensitive: false }
  
  # SCOPES
  scope :with_active_jobs, -> { joins(:jobs).merge(Job.active)}
  scope :with_inactive_jobs, -> { joins(:jobs).merge(Job.inactive)}
  scope :on_shift, -> { joins(:shifts).merge(Shift.clocked_in)} 
  scope :off_shift, -> { joins(:shifts).merge(Shift.clocked_out)}
  scope :with_current_timesheet, -> { joins(:timesheets).merge(Timesheet.this_week)}

    
  scope :unassigned, -> { where(assigned: false) }
  scope :assigned, -> { where(assigned: true) }
  scope :new_start, -> { joins(:jobs).where(Job[:start_date].gteq(Date.today.beginning_of_week)) }
  scope :newly_added, -> { where("employees.created_at >= ?", 7.days.ago) }
  scope :tardy, -> {
                     joins(:timesheets).
                     where("timesheets.submitted_at <= ?", 7.days.ago).
                     group("employees.id")
                   }
  
  def company
    self.current_job.company if self.current_job.present?
  end
  
  def current_timesheet
    if self.timesheets.current_week.any?
      self.timesheets.current_week.last
    end
  end
  
  def mark_as_assigned!
    if self.jobs.active.empty?
      self.update(assigned: false)
    else
      self.update(assigned: true)
    end
    
  end 
  def check_if_assigned
    if self.current_job.present?

      self.assigned = true
    else
      self.assigned = false
    end
    
    return true
          
  end
  
  
  
  # def set_user_info

  #     self.email = self.user.email if self.email.nil?
  #     self.first_name = self.user.first_name if self.first_name.nil?
  #     self.last_name = self.user.last_name if self.last_name.nil?

  # end
  
    
  
  
  def clocked_in?
    if self.shifts.clocked_in.any?
      true
    else
      false
    end
  end
  
  def pay_rate
    self.current_job.pay_rate
  end
  
  def verified_active_job_as_current?
    if self.shifts.last.id == self.current_job.shifts.last.id
     true
    else
      false
    end
  end
    
  def name
    "#{first_name} #{last_name}"
  end

    
  def ytd_gross_pay
    if self.timesheets.any?
      self.timesheets.sum(:gross_pay)
    else
      0
    end
  end
    
  def current_job_hours
    if self.current_job.any?
      self.current_job.shifts.sum(:time_worked)
    else
      0
    end
  end
    
  def total_all_hours
    if self.shifts.any?
      self.shifts.sum(:time_worked)
    else
      0
    end
  end
  
  #     # EXPORT TO CSV
  # def self.assign_from_row(row)
  #   employee = Employee.where(email: row[:email]).first_or_initialize
  #   timesheet = Timesheet.new row.to_hash.slice(:first_name, :last_name, :email, :profile_type, :role)
  #   employee
  # end
  
  # def self.to_csv
  #   attributes = %w{id last_name first_name email profile_type role}
  #   CSV.generate(headers: true) do |csv|
  #     csv << attributes
      
  #     all.each do |user|
  #       csv << user.attributes.values_at(*attributes)
  #     end
  #   end
  # end
    
    

      

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end
