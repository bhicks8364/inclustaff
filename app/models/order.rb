# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  notes                     :text
#  number_needed             :integer
#  needed_by                 :datetime
#  urgent                    :boolean
#  active                    :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  title                     :string
#  deleted_at                :datetime
#  manager_id                :integer
#  jobs_count                :integer
#  account_manager_id        :integer
#  mark_up                   :decimal(, )
#  agency_id                 :integer
#  dt_req                    :string
#  bg_check                  :string
#  heavy_lifting             :boolean
#  stwb                      :boolean
#  est_duration              :string
#  shift                     :string
#  bwc_code                  :string
#  min_pay                   :decimal(, )
#  max_pay                   :decimal(, )
#  pay_frequency             :string
#  address                   :string
#  latitude                  :float
#  longitude                 :float
#  aca_type                  :string
#  education                 :hstore           default({})
#  requirements              :hstore           default({})
#  industry                  :string
#  published_at              :datetime
#  published_by              :integer
#  expires_at                :datetime
#  mobile_time_clock_enabled :boolean          default(FALSE)
#
# Indexes
#
#  index_orders_on_account_manager_id  (account_manager_id)
#  index_orders_on_agency_id           (agency_id)
#  index_orders_on_deleted_at          (deleted_at)
#  index_orders_on_industry            (industry)
#  index_orders_on_manager_id          (manager_id)
#  index_orders_on_published_by        (published_by)
#

class Order < ActiveRecord::Base
  belongs_to :agency
  belongs_to :company
  has_many :events, foreign_key: "eventable_id"
  has_many :invoices, through: :timesheets
  belongs_to :manager, foreign_key: 'manager_id', class_name: "CompanyAdmin"
  belongs_to :account_manager, foreign_key: 'account_manager_id',  class_name: "Admin"
  has_many :skills, as: :skillable
  has_many :jobs, -> { where state: "Currently Working" }, class_name: "Job"
  has_many :pending_jobs, -> { where state: "Pending Approval" }, class_name: "Job"
  has_many :presented_candidates, through: :pending_jobs
  has_many :timesheets, :through => :jobs
  has_many :current_timesheets, :through => :jobs
  has_many :comments, as: :commentable
  has_many :inactive_jobs, -> { where active: false }, class_name: "Job"
  has_many :employees, :through => :jobs
  has_many :users, through: :employees
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  acts_as_taggable
  
  store_accessor :requirements, :agency_approval, :company_approval, :years_of_experience, :certifications, :requirement_1, :requirement_2, :requirement_3, :requirement_4
  # VALIDATIONS
  validates_associated :company
  validates :title, :number_needed,  presence: true
  validates :mark_up, :min_pay, :max_pay, :account_manager_id,  presence: true

  validates :company_id,  presence: true
  validates :needed_by, presence: true
  # CALLBACKS
  after_initialize :defaults
  before_validation :set_mark_up
  after_save :set_note_skills
  #  GEOCODER
  geocoded_by :address
  after_validation :set_address, :geocode
  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :jobs
  
  accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true

  # SCOPES
  scope :needing_company_approval, -> { where("requirements ? :key", :key => 'company_approval')}
  scope :needing_agency_approval, -> { where("requirements ? :key", :key => 'agency_approval')}
  scope :active, -> { where(active: true)}
  scope :inactive, -> { where(active: false)}
  scope :urgent, -> { where(urgent: true)}
  scope :with_active_jobs, -> { joins(:jobs).merge(Job.active)}
  scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.current_week)}
  scope :off_shift, -> { joins(:jobs).merge(Job.off_shift)}
  scope :needs_attention, -> { active.where(Order[:number_needed].gt(Order[:jobs_count])) }
  scope :priority, -> { needs_attention.where(Order[:needed_by].lteq(Time.current + 3.days))}
  scope :newly_added, -> { needs_attention.where(Order[:created_at].gteq(Time.current - 1.day))}
  scope :overdue, -> { needs_attention.where(Order[:needed_by].lteq(Time.current))}
  scope :published, -> { needs_attention.where(Order[:published_at].lteq(Time.current))}
  scope :unpublished, -> { needs_attention.where(Order[:published_at].eq(nil))}
  scope :long,    -> { where(NamedFunction.new("LENGTH", [Order[:notes]]).gt(200))}
  def self.filled
    OrderQueryBuilder.new.filled
  end
  def defaults
    self.needed_by = Date.today + 5.days if self.needed_by.nil?
    # Just putting this in here until I figure out how to format bootstrap datepicker
    self.active = true if self.active.nil?
    self.urgent = false if self.urgent.nil?
    self.jobs_count = 0 if self.jobs_count.nil?
    self.aca_type = "Variable-Hour" if aca_type.nil?
    self.requirements = {} if requirements.nil?
    # self.account_manager = company.current_account_manager if account_manager_id.nil?
  end
  def set_account_manager
    self.account_manager = Admin.account_managers.first
  end

  def set_mark_up
    self.title = title.titleize
    if max_pay.present? && mark_up.nil?
      case max_pay
      when (8..10)
        self.mark_up = 1.5
      when (11..12)
        self.mark_up = 1.55
      when (12..18)
        self.mark_up = 1.60
      when (18..30)
        self.mark_up = 1.65
      else
        self.mark_up = 1.55
      end
    end
  end
  
  def status
      if overdue?
          "Overdue"
      elsif priority?
         "Priority"
      elsif needs_attention?
          "Open"
      elsif filled?
         "Filled"
      elsif inactive?
          "Inactive"
      else
          ""
      end
    
  end
  def inactive?
    active == false
  end
  
  def to_param
    "#{id}-#{title.parameterize }"
  end
  
  def needs_agency_approval?; requirements['agency_approval'] == "true"; end
  def needs_company_approval?;  requirements['company_approval'] == "true";  end
  def needs_approval?;  needs_agency_approval? || needs_company_approval?;  end

  def send_approval_notifications!
    # TODO
    # sends notification to the account manager if needs_agency_approval?
    # send notifications to the manager if needs_company_approval?
  end

  def set_address
    self.address = "#{company.address} #{company.city}, #{company.state}" if address.blank? && company.present?
  end

  def self.by_recruiter(admin_id)
      joins(:jobs).where( :jobs => { :recruiter_id => admin_id } )
  end
  def self.with_no_timesheets
    where(active: true)
  end

  def pay_range
    "#{min_pay} - #{max_pay}"
  end
  def location
    "#{company.city}, #{company.state}"
  end
  def not_urgent?
    urgent == false
  end
  def overdue?
    needs_attention? && needed_by <= Date.today
  end
  def priority?
    needs_attention? && needed_by <= Date.today + 1.week
  end
  def set_needed_by
    if needed_by.nil?
      self.needed_by = Date.today
    end
  end

  def needs_attention?
    active? && number_needed > jobs.active.count
  end

  def filled?
    open_jobs == 0
  end
  
  def has_pending_jobs?
    jobs.pending_approval.any?
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
    title
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
    @note_skills = Skill.where(name: keywords).distinct
    @note_skills
    
    # @all_skills = @note_skills + skills.select(:name).distinct
    # @all_skills.uniq
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


  def self.assign_from_row(row, company_id)
    order = Order.where(id: row[:id], company_id: row[:company_id]).first_or_initialize
    order.assign_attributes row.to_hash.slice(:title, :min_pay, :max_pay, :number_needed, :needed_by, :notes, :est_duration)
    order.company_id = company_id
    if order.needed_by.blank?
        order.needed_by = Date.today + 3.days
    else
        order.needed_by = Chronic.parse(row[:needed_by])
    end
    order
  end

   # EXPORT TO CSV
  def self.to_csv
    attributes = %w{id agency_id company_id title min_pay max_pay pay_frequency account_manager_id manager_id mark_up title notes number_needed needed_by urgent active dt_req bg_check stwb heavy_lifting shift est_duration}
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
    Employee.available.tagged_with(skill_list, :match_all => true)
  end
  def matching_any
    Employee.available.tagged_with(tag_list, :any => true, :wild => true)
  end


end
