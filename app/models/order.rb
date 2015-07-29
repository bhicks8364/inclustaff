# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  company_id    :integer
#  pay_range     :string
#  notes         :text
#  number_needed :integer
#  needed_by     :datetime
#  urgent        :boolean
#  active        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string
#

class Order < ActiveRecord::Base
  has_many :jobs, inverse_of: :order
  has_many :employees, :through => :jobs
  has_many :timesheets, :through => :jobs
  belongs_to :company, inverse_of: :orders
  
  validates_associated :company
  validates :title,  presence: true
  
    # CALLBACKS
    after_initialize :defaults

    # SCOPES
    scope :active, -> { where(active: true)}
    scope :inactive, -> { where(active: false)}
    scope :urgent, -> { where(urgent: true)}
    scope :with_active_jobs, -> { joins(:jobs).merge(Job.active)}
    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.this_week)}
    
    
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
  









end
