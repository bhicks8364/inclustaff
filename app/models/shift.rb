# == Schema Information
#
# Table name: shifts
#
#  id             :integer          not null, primary key
#  time_in        :datetime
#  time_out       :datetime
#  employee_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_worked    :decimal(, )
#  job_id         :integer
#  state          :string
#  earnings       :decimal(, )
#  timesheet_id   :integer
#  deleted_at     :datetime
#  in_ip          :string
#  out_ip         :string
#  week           :integer
#  note           :text
#  needs_adj      :boolean
#  break_duration :decimal(, )
#  breaks         :text             is an Array
#  break_in       :datetime         is an Array
#  break_out      :datetime         is an Array
#  paid_breaks    :boolean          default(FALSE)
#  pay_rate       :decimal(, )
#

class Shift < ActiveRecord::Base
  extend SimpleCalendar
  # has_calendar :attribute => :time_in
  include ArelHelpers::ArelTable
  include Arel::Nodes
  acts_as_paranoid
  
  belongs_to :job
  belongs_to :timesheet, counter_cache: true
  has_one :employee, through: :job
  belongs_to :company, class_name: "Company", foreign_key: "company_id"
  has_many :comments, as: :commentable
  has_many :events, as: :eventable
  accepts_nested_attributes_for :job
  

  delegate :employee, to: :job
  delegate :order, to: :job
  delegate :manager, to: :job
  delegate :code, to: :employee
  delegate :week_ending, to: :timesheet
  
  validates :job_id, presence: true
  validates :time_in, presence: true
  
  scope :with_recent_comments,    -> { joins(:comments).merge(Comment.payroll_week)}
  scope :with_break,    -> { where.not(breaks: [])}
  scope :with_no_break, -> { where(breaks: [])}
  scope :clocked_in,    -> { where(state: "Clocked In")}
  scope :at_work,       -> { where.not(state: "Clocked Out")}
  scope :clocked_out,   -> { where(state: ["Clocked Out", nil])}
  scope :on_break,      -> { where(state: "On Break")}
  scope :with_notes,    -> { where(NamedFunction.new("LENGTH", [Shift[:note]]).gt(2))}
  scope :short_shifts,  -> { where('time_worked > 4') }
  scope :over_8,        -> { where('time_worked > 8') }
  
  def self.worked_before(date)
    where(Shift[:time_in].lteq(date))
  end
  def self.worked_after(date)
    where(Shift[:time_in].gteq(date))
  end
  def self.occurring_between(date1, date2)
    where(Shift[:time_in].gteq(date1)
    .and(Shift[:time_in].lteq(date2)))
  end
  
  
  scope :last_week,     -> { where(week: Date.today.cweek - 1)}
  scope :payroll_week,  -> {
          start = Time.current.beginning_of_week
          ending = start.end_of_week + 7.days
          where(time_in: start..ending)}
  scope :current_week, -> {
          start = Time.current.beginning_of_week
          ending = start.end_of_week
          where(time_in: start..ending)}
  scope :today, -> {
          start = Date.today.beginning_of_day
          ending = Date.today.end_of_day
          where(time_in: start..ending)}
  scope :yesterday, -> {
          start = Date.yesterday.beginning_of_day
          ending = Date.today.beginning_of_day
          where(time_in: start..ending)}

  after_save :update_timesheet!
  before_save :set_week, :set_timesheet, :calculate_break, :reg_earnings
  after_initialize :set_defaults, if: :new_record?
  after_initialize :set_pay
  
  def clocked_in?; state == "Clocked In"; end
  def clocked_out?; state == "Clocked Out"; end
  def on_break?; state == "On Break"; end
  
  def name; employee.name; end
  def shift_data; [employee.name, time_in, time_out]; end
  def took_a_break?; breaks.any?; end
    
  def calculate_break
    if clocked_in? && breaks.count.even?
      @breaks = breaks 
      @break_times = @breaks.map(&:to_datetime)
      @durations = []
      @break_times.in_groups_of(2) do |group| 
                      @durations  << time_diff(group[0], group[1])
                  end
     
      self.break_duration = @durations.sum 
    else 
      # This should throw an error because theyre still on break. 
      # Gotta clock out first. Maybe I should use AASM for this?? idk
    end
  end
  
  def self.report_by_month
    group_by_month(:time_in).sum(:time_worked)
  end
  def self.report_by_week
    group_by_week(:time_in).sum(:time_worked)
  end
  def self.report_by_year
    group_by_year(:time_in).sum(:time_worked)
  end
  
  def remove_all_breaks!
    state = (time_out > time_in) ? "Clocked Out" : "Clocked In"
    update(
      breaks:        [],
      break_in:      [],
      break_out:     [],
      break_duration: 0,
      state:       state
      )
  end
  def set_pay
    self.pay_rate = job.pay_rate if pay_rate.nil?
    self.break_duration = 0 if break_duration.nil?
  end
  def set_defaults
      self.employee = job.employee if employee.nil? 
      self.in_ip = employee.current_sign_in_ip if in_ip.nil?
      self.break_out = [] if break_out.nil?
      self.break_in = [] if break_in.nil?
      self.breaks = [] if breaks.nil?
      
     
  end
  
  def set_timesheet
      timesheet = Timesheet.find_or_create_by(job_id: job_id, week: week)
      self.timesheet = timesheet
  end

  def clock_in!
    if job.off_shift?
      self.job.shifts.create(
          time_in: Time.current, 
          time_out: nil, 
          week: Date.today.cweek,
          state: "Clocked In",
          in_ip: "admin-clock-in",
          out_ip: nil)
    end
  end
  
  def clock_out!
      update(time_out: Time.current,
                  state: "Clocked Out")
  end
  
  def self.clock_out_all!
      Shift.clocked_in.each {|s| s.update(time_out: Time.current, state: "Clocked Out") }
  end

  def hours_worked
      if clocked_in? || on_break?
          time_diff(time_in, Time.current)
      elsif clocked_out?
          time_diff(time_in, time_out)
      end
  end
  
  def pay_time
      if paid_breaks == false && break_duration > 0.01
          hours_worked - break_duration
      else
          hours_worked
          
      end
  end
  
  def reg_earnings
      @payable_hours = pay_time
      self.earnings = pay_rate * @payable_hours
      self.time_worked = @payable_hours
  end
  def set_week
    if time_out.nil?
      self.week = time_in.beginning_of_week.to_datetime.cweek
    else
      self.week = time_out.beginning_of_week.to_datetime.cweek
    end
    
  end

  def update_timesheet!
      timesheet.save
  end
  
  def delete_timesheet
    if timesheet.shifts.count.zero?
      timesheet.destroy
    end
  end
  
  def with_paid_breaks
    paid_breaks = hours_worked * pay_rate
    paid_breaks.round(2)
  end
  def with_unpaid_breaks
    @break_duration ||= break_duration? ? break_duration : 0
    unpaid_breaks = (hours_worked - @break_duration) * pay_rate
    unpaid_breaks.round(2)
  end
  
  
  private
  
  def time_diff(start_time, end_time)
      TimeDifference.between(start_time, end_time).in_hours
  end

end
