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
#

class Employee < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user
  has_many :shifts, inverse_of: :employee, dependent: :destroy
  has_many :jobs, inverse_of: :employee, dependent: :destroy
  has_many :orders, :through => :jobs
  has_many :companies, :through => :orders
  has_one :current_job, -> { where active: true }, class_name: "Job"
  has_many :timesheets, :through => :jobs


  accepts_nested_attributes_for :jobs
  accepts_nested_attributes_for :user
  
  delegate :company, to: :user
  before_save :set_user_info
  
  

  
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
  scope :with_current_timesheet, -> { joins(:timesheets).merge(Timesheet.this_week)}
  
  def set_user_info
    self.email = self.user.email
    self.first_name = self.user.first_name
    self.last_name = self.user.last_name
  end
  
    
  def unassigned?
    if self.jobs.any?
      false
    else
      true
    end
  end
  
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
    if self.timesheets.by_year.any?
      self.timesheets.by_year.sum(:gross_pay)
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
    
  # def current_company
  #   if self.jobs.active.any?
  #     self.current_job.company
  #   else
  #   "Unassigned"
  #   end
  # end
  
  def self.email
    if self.user != nil
      self.email = self.user.email
    else
      self.email 
    end
  end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end
