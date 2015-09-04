# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  company_id         :integer
#  pay_range          :string
#  notes              :text
#  number_needed      :integer
#  needed_by          :datetime
#  urgent             :boolean
#  active             :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  title              :string
#  deleted_at         :datetime
#  manager_id         :integer
#  jobs_count         :integer
#  account_manager_id :integer
#

class Order < ActiveRecord::Base
  belongs_to :company
  belongs_to :manager, foreign_key: 'manager_id', class_name: "Admin"
  belongs_to :account_manager, foreign_key: 'account_manager_id',  class_name: "Admin"
  has_many :jobs
  has_many :employees, :through => :jobs
  has_many :timesheets, :through => :jobs
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  
  # VALIDATIONS
  validates_associated :company
  validates :title,  presence: true
  
    # CALLBACKS
    after_initialize :defaults
    
    # NESTED ATTRIBUTES
    accepts_nested_attributes_for :jobs

    # SCOPES
    scope :active, -> { where(active: true)}
    scope :inactive, -> { where(active: false)}
    scope :urgent, -> { where(urgent: true)}
    scope :with_active_jobs, -> { joins(:jobs).merge(Job.active)}
    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.this_week)}
    scope :off_shift, -> { joins(:jobs).merge(Job.off_shift)}
    
    
    def defaults
      self.active = true if self.active.nil?
    end  
    
    def company_name
      if self.company
        self.company.name
      else
        "Company Unavailable"
      end
    end
    
  def needs_attention?
    if self.jobs && self.active
      if self.number_needed > self.jobs.count 
        true
      else
        false
      end
    end
  end
  
    # def open_jobs
    #   self.number_needed - self.jobs.active.count
    # end
    

    
  def self.by_manager(admin_id)
    where(manager_id: admin_id)
  end 
  









end
