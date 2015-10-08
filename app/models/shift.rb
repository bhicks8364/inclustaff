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
#  break_in       :datetime
#  break_out      :datetime
#  note           :text
#  needs_adj      :boolean
#  break_duration :decimal(, )
#

class Shift < ActiveRecord::Base
    extend SimpleCalendar
    # has_calendar :attribute => :time_in
    include ArelHelpers::ArelTable

    
    acts_as_paranoid

    # include AASM
    
    belongs_to :employee
    belongs_to :job
    belongs_to :timesheet, counter_cache: true
    belongs_to :company, class_name: "Company", foreign_key: "company_id"
    
    scope :last_week, ->{
        where(week: Date.today.cweek - 1)
    }
    scope :today, -> { where(time_in: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
    scope :short_shifts, -> { where('time_worked > 4') }
    scope :over_8, -> { where('time_worked > 8') }

    # has_one :order, through: :job
    # has_one :company, through: :order
    
    # validates_associated :employee
    validates :job_id, presence: true
    validates :time_in, presence: true

    delegate :pay_rate, to: :job
    delegate :order, to: :job
    delegate :manager, to: :job
    delegate :code, to: :employee
    delegate :week_ending, to: :timesheet
    accepts_nested_attributes_for :job
    
    
    after_save :update_timesheet!
    before_save :set_timesheet, :reg_earnings
    before_create :set_defaults
    # after_destroy :delete_timesheet
    def start_date
        time_in
    end

    def set_defaults
        self.employee = self.job.employee if self.employee.nil? 
        self.in_ip = self.employee.current_sign_in_ip if self.in_ip.nil?
        
    end
    
    def set_timesheet
       
        timesheet = Timesheet.find_or_create_by(job_id: self.job_id, week: self.week)
        self.timesheet = timesheet
    end
    
    def to_s
        "#{self.hours_worked.round(2)}     #{self.time_in.strftime('%m/%d   %r')} - #{self.time_out? ? self.time_out.strftime('%r') : self.state }"
    end
    
    # def clock_in!
    #     self.update(time_in: Time.current, time_out: nil,
    #                 state: "Clocked In",
    #                 out_ip: nil)
    # end
    def clock_in!
        if self.job.off_shift?
            self.job.shifts.create(time_in: Time.current, time_out: nil, week: Date.today.cweek,
                    state: "Clocked In",
                    in_ip: "admin-clock-in",
                    out_ip: nil)
        end
        # self.update(time_in: Time.current, time_out: nil,
        #             state: "Clocked In",
        #             out_ip: nil)
    end
    def clock_out!
        self.update(time_out: Time.current,
                    state: "Clocked Out")
    end
    
    
    
    
    def clocked_in?
        if self.state == "Clocked In"
            true
        else
            false
        end
    end
    def clocked_out?
        if self.state == "Clocked Out"
            true
        else
            false
        end
    end
    def on_break?
        if self.state == "On Break"
            true
        else
            false
        end
    end
    
    def employee_name
        self.employee.name
    end
    
    # SCOPES
    scope :payroll_week, ->{
        start = Time.current.beginning_of_week
        ending = start.end_of_week + 7.days
        where(time_in: start..ending)
    }
    scope :current_week, ->{
        start = Time.current.beginning_of_week
        ending = start.end_of_week
        where(time_in: start..ending)
    }
    scope :in_today, ->{
        start = Date.today.beginning_of_day
        ending = Date.today.end_of_day
        where(time_in: start..ending)
    }
    scope :in_yesterday, ->{
        start = Date.yesterday.beginning_of_day
        ending = Date.today.beginning_of_day
        where(time_in: start..ending)
    }
    
    scope :clocked_in, ->{
        where(state: "Clocked In")
    }
    scope :clocked_out, ->{ where(state: ["Clocked Out", nil])}
    scope :on_break, ->{
        where(state: "On Break")
    }
    
    def hours_worked
        if self.clocked_in?
            time_diff(self.time_in, Time.current).round(2)
        else
            time_diff(self.time_in, self.time_out).round(2)
        end
    end
    


    
    def reg_earnings
        self.time_worked = self.hours_worked
        
        self.earnings = self.pay_rate * self.hours_worked
        
    end

    
    def break_time
        if self.break_out != nil
            time = self.break_in - self.break_out
            time = time / 3600
            time.round(2)
        else
            0.00
        end
    end
    def took_a_break?
        if break_time > 0.1
            true
        else
            false
        end
    end

    # def calculate_time

    #     if time_out.present? && time_in.present?
    #         end_time = self.time_out
    #         start_time = self.time_in
    #         time = (end_time - start_time)
    #         time = time / 3600
    #         self.time_worked = time.round(2)
    #     else
    #         self.time_worked = 0.00
    #     end

    # end
    

    
    def update_timesheet!
        self.timesheet.update(updated_at: Time.current)
        
    end
    

    # def set_week
    #     self.week = self.time_in.cweek
    # end

    
    def self.last_week
      where(:time_in => 1.week.ago.beginning_of_week..1.week.ago.end_of_week)
    end
    
    def self.yesterday
      where(:time_in => 1.day.ago.beginning_of_day..1.day.ago.end_of_day)
    end
    
    

   

    def delete_timesheet
      if timesheet.shifts.count.zero?
        timesheet.destroy
      end
    end
    
    
    private
    
    def time_diff(start_time, end_time)
      seconds_diff = (start_time - end_time).to_f.abs
    
      hours = seconds_diff / 3600
    #   seconds_diff -= hours * 3600
    # time_diff(s.time_in, s.time_out)
    #   minutes = seconds_diff / 60
    #   seconds_diff -= minutes * 60
    
    #   seconds = seconds_diff
      
     return hours.to_d
    
    #   "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end
    

    
    
end
