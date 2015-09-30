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
#  mark_up            :decimal(, )
#  agency_id          :integer
#  dt_req             :string
#  bg_check           :string
#  heavy_lifting      :boolean
#  stwb               :boolean
#  est_duration       :string
#  shift              :string
#

class Order < ActiveRecord::Base
  belongs_to :agency
  belongs_to :company
  belongs_to :manager, foreign_key: 'manager_id', class_name: "Admin"
  belongs_to :account_manager, foreign_key: 'account_manager_id',  class_name: "Admin"
  has_many :skills, as: :skillable
  has_many :jobs
  has_many :employees, :through => :jobs
  has_many :timesheets, :through => :jobs
  has_many :current_timesheets, :through => :jobs
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  
  # VALIDATIONS
  validates_associated :company
  validates :title,  presence: true
  validates :mark_up,  presence: true
  validates :agency_id,  presence: true
  validates :company_id,  presence: true
  
    # CALLBACKS
    after_initialize :defaults
    before_validation :set_mark_up
    
    
    # NESTED ATTRIBUTES
    accepts_nested_attributes_for :jobs
    accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true

    # SCOPES
    scope :active, -> { where(active: true)}
    scope :inactive, -> { where(active: false)}
    scope :urgent, -> { where(urgent: true)}
    scope :with_active_jobs, -> { joins(:jobs).merge(Job.active)}
    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.current_week)}
    scope :off_shift, -> { joins(:jobs).merge(Job.off_shift)}
    scope :needs_attention, -> { where(Order[:number_needed].gt(Order[:jobs_count])) }
    scope :filled, -> { where(Order[:jobs_count].gteq(Order[:number_needed])) }
    
    def defaults
      self.active = true if self.active.nil?
      self.urgent = false if self.urgent.nil?
      self.jobs_count = 0 if self.jobs_count.nil?
    end
    # [ "$8.10 - $10.00","$10.00 - $12.00","$12.00 - $15.00", 
      # "$15.00 - $18.00", "$18.00 - $22.00", "$18.00 - $22.00", "$22.00 +  ", "Salary", "Hourly + Commission"]
    def set_mark_up
      case pay_range
      when "$8.10 - $10.00"
        self.mark_up = 1.5
      when "$10.00 - $12.00"
        self.mark_up = 1.5
      when "12.00 - $15.00"
        self.mark_up = 1.55
      when "15.00 - $18.00"
        self.mark_up = 1.6
      when "$18.00 - $22.00"
        self.mark_up = 1.6
      when "$22.00 +  "
        self.mark_up = 1.65
      else
        self.mark_up = 1.5
      end
    end
        
    
    def company_name
      if self.company
        self.company.name
      else
        "Company Unavailable"
      end
    end
    
  def needs_attention?
    if self.jobs.any?
      j = self.jobs.count
    else
      j = 0
    end
    if self.number_needed && self.active
      if self.number_needed > j 
        true
      else
        false
      end
    end
  end
  
  def filled?
    if self.number_needed <= self.jobs_count 
        true
      else
        false
    end
  end
  
    def open_jobs
      if self.number_needed != nil && self.jobs != nil
        self.number_needed - self.jobs.count
      end
    end
    

    
  def self.by_manager(admin_id)
    where(manager_id: admin_id)
  end
  
  def self.by_account_manager(admin_id)
    where(account_manager_id: admin_id)
  end 
  
  def title_company
    "#{company_name} - #{title}"
  end
  
  def title_count
    "#{title} (#{pay_range}) #{open_jobs}"
  end
  
  def mark_up_percent
    (self.mark_up * 100 - 100).to_i.to_s + "%" 
  end
  
  
  def applications
      Event.where(eventable_id: self.id, eventable_type: 'Order', action: 'applied')
  end









end
