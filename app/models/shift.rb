# == Schema Information
#
# Table name: shifts
#
#  id           :integer          not null, primary key
#  time_in      :datetime
#  time_out     :datetime
#  employee_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  time_worked  :decimal(, )
#  job_id       :integer
#  state        :string
#  earnings     :decimal(, )
#  timesheet_id :integer
#

class Shift < ActiveRecord::Base
    extend SimpleCalendar
    has_calendar :attribute => :time_in
    
    belongs_to :employee, inverse_of: :shifts
    belongs_to :job, inverse_of: :shifts
    belongs_to :timesheet, inverse_of: :shifts
    belongs_to :company, class_name: "Company", foreign_key: "company_id"

    # has_one :order, through: :job
    # has_one :company, through: :order
    
    validates_associated :employee
    validates_associated :job
    validates :job_id, presence: true
    validates :employee_id, presence: true
    validates :time_in, presence: true
    
    delegate :pay_rate, to: :job

    
    accepts_nested_attributes_for :job
    
    before_save :calculate_time!, :set_timesheet
    after_initialize :defaults
    
    
    def defaults
        if self.new_record?
            self.time_in = Time.current
            self.state = "clocked_in"
            self.time_out = self.time_in
            self.earnings = 0.00
        end
    end
    
    def set_timesheet
        self.timesheet = Timesheet.find_or_create_by(job_id: self.job_id, week: Date.today.cweek)
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
        where(state: "clocked_in")
    }
    scope :clocked_out, ->{
        where(state: "clocked_out")
    }
    
    
    def clocked_in?
        if self.state == "clocked_in"
            true
        else
            false
        end
    end
    
    def clocked_out?
        if self.state == "clocked_out"
            true
        else
            false
        end
    end
    
    def clock_out!
        self.update(time_out: Time.current,
                    state: "clocked_out")
    end
    
    # def company
    #     self.job.order.company
    # end
    
    # def gross_earnings
    #     self.current_week.sum(:time_worked)
    # end
    
    
    # def self.time_worked
    #     time = self.time_out - self.time_in
    #     time = time / 3600
    #     time.round(2)
    # end
    
    def calculate_time!
        if self.time_out != nil
            time = self.time_out - self.time_in
            time = time / 3600
            self.time_worked = time.round(2)
        else
            self.time_worked = 0.00
        end
    end
    
    # def set_company
        # self.job.company.id = self.company_id
    # end
    def week
        self.time_out.end_of_week.to_datetime.cweek
    end
    
    def week_ending
        self.time_out.end_of_week
    end
    
    def self.last_week
      where(:time_in => 1.week.ago.beginning_of_week..1.week.ago.end_of_week)
    end
    
    def self.yesterday
      where(:time_in => 1.day.ago.beginning_of_day..1.day.ago.end_of_day)
    end
    
    
end
