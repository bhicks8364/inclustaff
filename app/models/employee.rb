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
#  availablity      :hstore
#  dns              :boolean          default(FALSE)
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
  has_many :work_histories
  has_one :agency, through: :user
  has_many :shifts, through: :jobs, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :orders, :through => :jobs
  has_many :companies, :through => :orders
  has_one :current_job, -> { where active: true }, class_name: "Job"
  has_many :job_comments, through: :jobs, source: 'comments'
  has_many :comments, as: :commentable
  has_many :timesheets, :through => :jobs
  attachment :resume, extension: ["pdf", "doc", "docx"]

  accepts_nested_attributes_for :jobs
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :work_histories, reject_if: :all_blank, allow_destroy: true

  # This isnt working right. Think I should use arrays for this or maybe a new model all together. idk
  store_accessor :availablity, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday

  delegate :last_clock_in, to: :current_job
  delegate :last_clock_out, to: :current_job
  delegate :current_shift, to: :current_job
  delegate :account_manager, to: :current_job
  delegate :recruiter, to: :current_job
  delegate :code, to: :user
  delegate :current_sign_in_ip, to: :user

  after_save :create_user, if: :has_no_user?
  after_initialize :set_defaults

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
  scope :first_mondays, -> { where("availablity -> 'monday' = '1st shift'") }
  scope :first_tuesdays, -> { where("availablity -> 'tuesday' = '1st shift'") }
  scope :third_tuesdays, -> { where("availablity -> 'tuesday' = '3rd shift'") }
  scope :new_starts, -> { joins(:jobs).where(Job[:start_date].gteq(Date.today.beginning_of_week)) }
  scope :newly_added, -> { where("employees.created_at >= ?", 3.days.ago) }

  def company
    current_job.company if current_job.present?
  end
  def initial_start_date
    if shifts.any?
      shifts.order(:time_in).first.time_in

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
    shifts.group_by_week(:time_in, range: initial_start_date...Time.current).sum(:time_worked)
  end


  def current_status
    shifts.any? ? shifts.last.state.humanize : "No Shifts"
  end
  def total_hours
      shifts.sum(:time_worked)
  end
  def self.sorted_by_total_hours
    all.sort_by(&:total_hours).reverse!
  end
  # def current_report
  #   shifts.group_by_year(:time_in, range: Time.current.beginning_of_year.midnight...Time.current).sum(:time_worked)
  # end
  def current_report
    shifts.group_by_year(:time_in, range: initial_start_date...Time.current).sum(:time_worked)
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
    self.tag_list.add(work_tags)
    self.save
  end

  def mark_as_assigned!
    if jobs.active.any?
      self.update(assigned: true)
    else
      self.update(assigned: false)
    end
  end

  def set_defaults
    self.dns = false if dns.nil?
    self.assigned = false if assigned.nil?
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
      current_job.shifts.sum(:time_worked)
    else
      0
    end
  end

  def total_all_hours
      shifts.sum(:time_worked)
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
end
