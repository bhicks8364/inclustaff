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
#  bwc_code           :string
#  min_pay            :decimal(, )
#  max_pay            :decimal(, )
#  pay_frequency      :string
#  address            :string
#  latitude           :float
#  longitude          :float
#  aca_type           :string
#

class Order < ActiveRecord::Base
  belongs_to :agency
  belongs_to :company
  has_many :events, foreign_key: "eventable_id"
  has_many :invoices, through: :timesheets
  belongs_to :manager, foreign_key: 'manager_id', class_name: "CompanyAdmin"
  belongs_to :account_manager, foreign_key: 'account_manager_id',  class_name: "Admin"
  has_many :skills, as: :skillable
  has_many :jobs
  has_many :timesheets, :through => :jobs
  has_many :current_timesheets, :through => :jobs
  has_many :comments, as: :commentable
  has_many :active_jobs, -> { where active: true }, class_name: "Job"
  has_many :employees, :through => :active_jobs
  has_many :users, through: :employees
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  acts_as_taggable
  
  # VALIDATIONS
  validates_associated :company
  validates :title,  presence: true
  validates :mark_up, :min_pay, :max_pay,  presence: true

  validates :company_id,  presence: true
  validates :needed_by, presence: true
  
    # CALLBACKS
    after_initialize :defaults
    before_validation :set_mark_up, :set_pay_range
    after_save :set_note_skills
    # before_save :set_needed_by, if: :urgent?
    
  #  GEOCODER
  geocoded_by :address
  after_validation :geocode
    
    
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
    scope :priority, -> { needs_attention.where(Order[:needed_by].lteq(Time.zone.now + 3.days))}
    scope :newly_added, -> { needs_attention.where(Order[:created_at].gteq(Time.zone.now - 1.day))}
    scope :overdue, -> { needs_attention.where(Order[:needed_by].lteq(Time.zone.now))}
    
    def defaults
      self.active = true if self.active.nil?
      self.urgent = false if self.urgent.nil?
      self.jobs_count = 0 if self.jobs_count.nil?
      
      self.jobs_count = 0 if jobs_count.nil?
    end
   
    def set_mark_up
      if mark_up.nil? 
        case max_pay
        when (8..10)
          self.mark_up = 1.5
        when (11..12)
          self.mark_up = 1.55
        when (12..18)
          self.mark_up = 1.60
        when (18..25)
          self.mark_up = 1.65
        else
          self.mark_up = 1.5
        end
      end
    end
    
    def set_pay_range
      min = min_pay.to_s
      max = max_pay.to_s
      self.pay_range = min + " - " + max
      self.address = "#{company.address} #{company.city}, #{company.state}" if address.nil?
    end
    
    def self.by_recuriter(admin_id)
        joins(:jobs).where( :jobs => { :recruiter_id => admin_id } )
    end
    def self.with_no_timesheets
      where(active: true)
    end
    
    def not_urgent?
      urgent == false
    end
    def overdue?
      needs_attention? && needed_by <= Date.today
    end
    def priority?
      needs_attention? && needed_by <= Date.today + 3.days
    end
    def set_needed_by
      if needed_by.nil?
        self.needed_by = Date.today
      end
    end
    
  def needs_attention?
    if jobs.active.any?
      j = jobs.active.count
    else
      j = 0
    end
    if number_needed && active
      if number_needed > j 
        true
      else
        false
      end
    end
  end
  
  def filled?
    if number_needed <= jobs_count 
        true
      else
        false
    end
  end
  
  def open_jobs
    if number_needed != nil && jobs.active != nil
      number_needed - jobs.active.count

    end
  end
    

    
  def self.by_manager(admin_id)
    where(manager_id: admin_id)
  end
  
  def self.by_account_manager(admin_id)
    where(account_manager_id: admin_id)
  end 
  
  def title_company
    "#{company.name} - #{title}"
  end
  def to_s
    title_company
  end
  
  
  
  
  def mark_up_percent
    (mark_up * 100 - 100).to_i.to_s + "%" 
  end
  
  
  def applications
      Event.where(eventable_id: id, eventable_type: 'Order', action: 'applied')
  end

  def mentions
      @mentions ||= begin
                    regex = /([\w]+)/
                      if notes.present?
                        notes.scan(regex).flatten
                      end
                    end
  end

  def requested_employees
      @requested_employees ||= Employee.where(last_name: mentions)
  end
  
  def admin_mentions
      @mentions ||= begin
                      if notes.present?
                      regex = /([\w]+)/
                      notes.scan(regex).flatten
                      end
                    end
  end
  
  def mentioned_admins
      @mentioned_admins ||= Admin.where(username: admin_mentions)
  end
  
  def keywords
    
      @keywords ||= begin
                      if notes.present?
                      regex = /([\w]+)/
                      notes.scan(regex).flatten
                      end
                    end
  end
  
  def note_skills
    @note_skills ||= Skill.where(name: keywords).select(:name).distinct
    @all_skills = @note_skills + skills.select(:name).distinct
    @all_skills.uniq
  end
  
  def matching_skills
      @matching_skills ||= Employee.available.tagged_with([keywords], :any => true)
  end

  def matching_employees
     @matching_employees ||= Employee.available.tagged_with([tag_list], :any => true)
  end
  
  # def with_skills_matching(skills)
  #   include?(request.subdomain)
  # end
  
  
  def set_note_skills
    note_skills.each do |skill|
        self.skills.find_or_create_by(name: skill.name)
    end
  end
  
  
  def self.assign_from_row(row)
    order = Order.where(id: row[:id], company_id: row[:company_id]).first_or_initialize
    order.assign_attributes row.to_hash.slice(:title, :min_pay, :max_pay, :number_needed, :needed_by)
    
    order
  end
  
   # EXPORT TO CSV
  def self.to_csv
    attributes = %w{id agency_id company_id title min_pay max_pay pay_frequency account_manager_id manager_id mark_up title pay_range notes number_needed needed_by urgent active dt_req bg_check stwb heavy_lifting shift est_duration}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      
      all.each do |jo|
        csv << jo.attributes.values_at(*attributes)
      end
    end
  end
  
  def with_employee_skills
      tag_list = Order.needs_attention.tag_counts.pluck(:name)
	    Employee.available.tagged_with(tag_list, :any => true)
  end
  def self.skills_needed
    a = Order.needs_attention.tag_counts_on(:tags).pluck(:name, :taggings_count)
    b = Employee.available.tag_counts_on(:tags).pluck(:name, :taggings_count)
    c = a + b
    # a.delete_if { |x| b.include?(x.first) }
    c.to_h
  end
  def matching_all_requirments 
    skill_list = skills.required.pluck(:name)
    Employee.tagged_with(skill_list, :match_all => true)
  end
  def matching_any 
    Employee.tagged_with(tag_list, :any => true, :wild => true)
  end


end
