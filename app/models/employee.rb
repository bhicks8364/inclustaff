# == Schema Information
#
# Table name: employees
#
#  id               :integer          not null, primary key
#  first_name       :string
#  last_name        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  email            :string
#  ssn              :string
#  phone_number     :string
#  user_id          :integer
#  deleted_at       :datetime
#  assigned         :boolean
#  resume_id        :string
#  desired_job_type :string
#  desired_shift    :string
#  availability     :hstore
#  dns              :boolean          default(FALSE)
#  exsisting_hours  :decimal(, )      default(0.0)
#  aca_hours        :decimal(, )      default(0.0)
#  status           :string           default("New")
#
# Indexes
#
#  index_employees_on_availability  (availability)
#  index_employees_on_deleted_at    (deleted_at)
#  index_employees_on_email         (email)
#  index_employees_on_user_id       (user_id)
#

class Employee < ActiveRecord::Base
  acts_as_paranoid
  include ArelHelpers::ArelTable
  include ArelHelpers::JoinAssociation
  acts_as_taggable
  # acts_as_taggable_on :skills
  belongs_to :user
  has_many :skills, as: :skillable
  has_many :events, :through => :user
  has_many :direct_deposits
  has_many :job_events, :through => :jobs, source: 'events'
  has_many :work_histories
  has_one :agency, through: :user
  has_many :shifts, through: :jobs
  has_many :jobs, dependent: :destroy
  has_many :orders, :through => :jobs
  has_many :companies, :through => :orders
  has_one :current_job, -> { where(active: true, state: "Currently Working") }, class_name: "Job"
  has_many :job_comments, through: :jobs, source: 'comments'
  has_many :comments, as: :commentable
  has_many :timesheets, :through => :jobs
  attachment :resume, extension: ["pdf", "doc", "docx"]

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :work_histories, reject_if: :all_blank, allow_destroy: true
  
  # RANSACK
  ransack_alias :job, :job_title_or_description_cont
  # This isnt working right. Think I should use arrays for this or maybe a new model all together. idk
  store_accessor :availability, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday

  delegate :last_clock_in, to: :current_job
  delegate :last_clock_out, to: :current_job
  delegate :current_shift, to: :current_job
  delegate :account_manager, to: :current_job
  delegate :recruiter, to: :current_job
  delegate :company, to: :current_job
  delegate :code, to: :user
  delegate :mention_data, to: :user
  delegate :current_sign_in_ip, to: :user

  after_save :create_user, if: :has_no_user?
  after_initialize :set_defaults
  before_save :check_assigned
  
  def self.without_direct_deposit
      includes(:direct_deposits).where( :direct_deposits => { :employee_id => nil } )
  end  
  
  scope :working, -> { where(status: 'Working')}
  scope :needing_dd, -> { without_direct_deposit.where(status: 'Working').joins(:timesheets).merge(Timesheet.current_week)}
  def available?
    current_job.nil? && dns == false
  end
  def has_no_user?
    user_id.nil?
  end
  def name_title
    current_job.present? ? current_job.name_title : "#{name} - Unassigned"
  end
  def title
    current_job.present? ? current_job.title : "Unassigned"
  end
  def manager
    if assigned?
      current_job.manager.present? ? current_job.manager : current_job.company.admins.first
    end
  end

  

  # VALIDATIONS
  # validates :first_name,  presence: true, length: { maximum: 20 }
  # validates :last_name,  presence: true, length: { maximum: 20 }
  validates :user_id, presence: true
  # validates :ssn, length: { is: 4 }
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # validates :email, presence: true, length: { maximum: 255 },
  #                 format: { with: VALID_EMAIL_REGEX },
  #                 uniqueness: { case_sensitive: false }

  # SCOPES
  scope :with_late_timesheets, -> { joins(:timesheets).merge(Timesheet.needing_approval)}
  scope :with_active_jobs, -> { joins(:jobs).merge(Job.active)}
  scope :worked_this_year, -> { joins(:shifts).merge(Shift.this_year)}
  scope :with_inactive_jobs, -> { joins(:jobs).merge(Job.inactive)}
  scope :on_shift, -> { joins(:shifts).merge(Shift.clocked_in)}
  scope :at_work, -> { joins(:shifts).merge(Shift.at_work)}
  scope :off_shift, -> { joins(:current_shift).merge(Shift.clocked_out)}
  scope :with_current_timesheet, -> { joins(:timesheets).merge(Timesheet.this_week)}
  scope :on_break, -> { joins(:shifts).merge(Shift.on_break)}
  scope :dns, -> { where(dns: true) }
  scope :unassigned, -> { where(assigned: false) }
  scope :available, -> { unassigned.where(dns: false) }
  scope :assigned, -> { where(assigned: true) }
  scope :first_mondays, -> { where("availability -> 'monday' = '1st shift'") }
  scope :first_tuesdays, -> { where("availability -> 'tuesday' = '1st shift'") }
  scope :third_tuesdays, -> { where("availability -> 'tuesday' = '3rd shift'") }
  scope :new_starts, -> { joins(:jobs).where(Job[:start_date].gteq(Date.today.beginning_of_week).and(Job[:active].eq(true))) }
  scope :newly_added, -> { where("employees.created_at >= ?", 3.days.ago) }

  def initial_start_date
    if timesheets.any?
      timesheets.order(week: :desc).last.week
    else
      jobs.any? ? jobs.last.start_date : Date.today
    end
  end
  def days_from_initial_start
    if initial_start_date.present?
      TimeDifference.between(initial_start_date, Time.current).in_days
    else
      0
    end
  end
  def average_weekly_hours
    if total_hours > 1 && timesheets.any?
      @average = []
      timesheets.distinct.each do |timesheet|
        @average << timesheet.total_hours
      end
      (@average.sum / timesheets.count).round(2)
    end
  end

  def year_report
    timesheets.sum(:total_hours)
  end


  def current_status
    shifts.any? ? shifts.last.state.humanize : "No Shifts"
  end
  def total_hours
      timesheets.sum(:total_hours) + exsisting_hours
  end
  def self.sorted_by_total_hours
    all.sort_by(&:total_hours).reverse!
  end
  # def current_report
  #   shifts.group_by_year(:time_in, range: Time.current.beginning_of_year.midnight...Time.current).sum(:time_worked)
  # end
  def current_report
    timesheets.any? ? timesheets.group_by_week(:week, range: initial_start_date...Time.current).sum(:total_hours) : []
  end

  def current_timesheet
    if timesheets.current_week.any?
      timesheets.current_week.last
    else
      []
    end
  end

  def work_tags
    @work_tags ||= work_histories.map(&:tag_list).flatten
  end
  def work_history_data
    @histories ||= work_histories.order(:start_date).map { |work_history| ["#{work_history.title}", "#{work_history.start_date}", "#{work_history.end_date}"]}
    @jobs ||= jobs.map { |job| ["(#{job.order_id}00#{job.id}) - #{job.title}", "#{job.start_date}", "#{job.end_date.present? ? job.end_date : Date.today}"]}
    @histories + @jobs
  end
  def set_work_tags!
    self.tag_list = skills.pluck(:name)
  end

  def check_assigned
    if current_job.present?
      self.assigned = true
      self.status = "Working"
    elsif available?
      self.assigned = false
      self.status = "Available"
    elsif dns?
      self.status = "DNS"
    end
    true
  end

  def set_defaults
    self.dns = false if dns.nil?
    self.assigned = false if assigned.nil?
    self.desired_job_type = "Any" if desired_job_type.nil?
    self.desired_shift = "1st" if desired_shift.nil?
  end

  def unassigned?
    assigned == false
  end

  def on_shift?
    shifts.clocked_in.any?
  end
  def on_break?
    shifts.on_break.any?
  end
  def at_work?
    shifts.at_work.any?
  end

  def clocked_in?
    shifts.clocked_in.any?
  end

  def pay_rate
    current_job.pay_rate
  end

  def name; "#{first_name} #{last_name}"; end

  def create_user
    new_code = first_name[0,1] + last_name[0,1] + ssn + rand(1000..9999).to_s
    self.user = User.create(employee_id: id, first_name: first_name,
                      last_name: last_name, email: email,
                      password: new_code, password_confirmation: new_code, code: new_code)
  end


  def ytd_gross_pay
    if timesheets.any?
      timesheets.sum(:gross_pay)
    else
      0
    end
  end

  def current_job_hours
    if current_job.present?
      current_job.timesheets.sum(:total_hours)
    else
      0
    end
  end

  def total_all_hours
      timesheets.sum(:total_hours)
  end
  def matching_orders
     @matching_orders ||= Order.needs_attention.tagged_with([tag_list], :any => true)
  end
  # def matching_employees
  #   @matching_employees ||= Employee.unassigned.tagged_with([tag_list], :any => true)
  # end

      # EXPORT TO CSV
  def self.assign_from_row(row)
      employee = Employee.where(email: row[:email]).first_or_initialize
      employee.assign_attributes row.to_hash.slice(:first_name, :last_name, :user_id, :ssn, :desired_shift, :desired_job_type, :email, :phone_number)
      employee
  end

  def self.to_csv
    attributes = %w{id last_name first_name email ssn phone_number desired_job_type desired_shift user_id}
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |employee|
        csv << employee.attributes.values_at(*attributes)
      end
    end
  end
  
  def aca_report_pdf
    EmployeeAcaPdf.new(
      id: id,
      name: name,
      email: email,
      initial_start_date: initial_start_date,
      company_name: company.name,
      message: "ACA Report for #{name}  ",
      company: {
        name: "#{company.name}",
        address: "#{company.address}",
        email: "#{company.contact_email}",
        logo: Rails.root.join("app/assets/images/applicants.png")
      },
      line_items: [
        year_report.to_a.flatten,
        # ["Job Title",           title],
        # ["Employee:",           employee.name],
        # ["Recruiter:",          recruiter.name],
        # ["Interview Notes",     description],
        # ["Required Skills:",        "#{order.skills.required.order(:name).map(&:name).join(', ')}"],
        # ["Other Skills:",        "#{order.skills.additional.order(:name).map(&:name).join(', ')}"],
        # ["Candidate Skills:",        "#{employee.skills.order(:name).map(&:name).join(', ')}"],
        # ["Needed By",         order.needed_by.stamp('11/12/2015')],
        # ["Pay - Bill",         "$#{pay_rate.round(2)}  -  $#{bill_rate.round(2)}"],
        # ["Mark Up",         mark_up_percent],
        ["Start Date",         created_at.stamp('11/12/2015')]
      ]
    )
  end
end
