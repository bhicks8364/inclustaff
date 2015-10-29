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
#

class Shift < ActiveRecord::Base
  extend SimpleCalendar
  # has_calendar :attribute => :time_in
  include ArelHelpers::ArelTable
  acts_as_paranoid

  belongs_to :employee
  belongs_to :job
  belongs_to :timesheet, counter_cache: true
  belongs_to :company, class_name: "Company", foreign_key: "company_id"
  
  accepts_nested_attributes_for :job
  
  delegate :pay_rate, to: :job
  delegate :order, to: :job
  delegate :manager, to: :job
  delegate :code, to: :employee
  delegate :week_ending, to: :timesheet
  
  validates :job_id, presence: true
  validates :time_in, presence: true

  scope :with_break,    -> { where.not(breaks: nil)}
  scope :with_no_break, -> { where(breaks: nil)}
  scope :clocked_in,    -> { where(state: "Clocked In")}
  scope :at_work,       -> { where.not(state: "Clocked Out")}
  scope :clocked_out,   -> { where(state: ["Clocked Out", nil])}
  scope :on_break,      -> { where(state: "On Break")}
  
  scope :short_shifts,  -> { where('time_worked > 4') }
  scope :over_8,        -> { where('time_worked > 8') }
  
  scope :today,         -> {where(time_in: Time.current.beginning_of_day..Time.current.end_of_day) }
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
  before_create :set_defaults
  
  def clocked_in?; state == "Clocked In"; end
  def clocked_out?; state == "Clocked Out"; end
  def on_break?; state == "On Break"; end
  def to_s; "#{time_in.strftime('%l:%M%P')} - #{time_out? ? time_out.strftime('%l:%M%P') : state }"; end
  def shift_data
   "[#{employee.name}, #{time_in}, #{time_out}]"
  end
  def took_a_break?; breaks.any?; end
    
  def calculate_break
    if self.breaks.present? && self.breaks.count.even? 
      @breaks = self.breaks 
      @break_times = @breaks.map { |b| b.to_datetime }
      @new_array = []
      @break_times.in_groups_of(2) do |group| 
                      @new_array  << time_diff(group[0], group[1])
                  end
      @duration = @new_array.sum
      self.break_duration = @duration if @duration.present?
    else 
      
    end
  end
  
  
  def remove_all_breaks!
    state = (time_out > time_in) ? "Clocked In" : "Clocked In"
    update(
      breaks:        [],
      break_in:      [],
      break_out:     [],
      break_duration: 0,
      state:       state
      )
  end

  def set_defaults
      self.employee = self.job.employee if employee.nil? 
      self.in_ip = self.employee.current_sign_in_ip if in_ip.nil?
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

  def hours_worked
      if clocked_in? || on_break?
          time_diff(time_in, Time.current)
      elsif clocked_out?
          time_diff(time_in, time_out)
      end
  end
  
  def pay_time
      if self.break_duration.present? && self.break_duration > 0.01
          self.hours_worked - self.break_duration
      else
          self.hours_worked
          
      end
  end
  
  def reg_earnings
      @payable_hours = self.pay_time
      self.earnings = self.job.pay_rate * @payable_hours
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
      self.timesheet.update(updated_at: Time.current)
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
    unpaid_breaks = pay_time * pay_rate
    unpaid_breaks.round(2)
  end
  
  
  private
  
  def time_diff(start_time, end_time)
      TimeDifference.between(start_time, end_time).in_hours
  end

end
