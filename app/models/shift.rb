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
#  deleted_at   :datetime
#

class Shift < ActiveRecord::Base
    extend SimpleCalendar
    has_calendar :attribute => :time_in
    include ArelHelpers::ArelTable
    by_star_field :time_in, :time_out

    
    
    belongs_to :employee, inverse_of: :shifts
    belongs_to :job, inverse_of: :shifts
    belongs_to :timesheet, inverse_of: :shifts
    belongs_to :company, class_name: "Company", foreign_key: "company_id"
    
    scope :last_week, ->{
        where(week: Date.today.cweek - 1)
    }
    
    scope :short_shifts, -> { where('time_worked > 4') }
    scope :over_8, -> { where('time_worked > 8') }

    # has_one :order, through: :job
    # has_one :company, through: :order
    
    # validates_associated :employee
    validates_associated :job
    validates :job_id, presence: true
    # validates :employee_id, presence: true
    validates :time_in, presence: true
    
    delegate :pay_rate, to: :job
    delegate :employee, to: :job
    delegate :order, to: :job
    delegate :manager, to: :job

    
    accepts_nested_attributes_for :job
    
    after_save :update_timesheet!
    before_save :set_timesheet, :calculate_time, :reg_earnings, :set_employee
    
    after_initialize :defaults
    
    # SCOPES
    # @post.next(scope: Post.where(category: @post.category))
    
    
    def defaults
        if self.new_record?
            self.time_in = Time.current
            self.state = "clocked_in"
            self.time_out = self.time_in
            self.earnings = 0.00
            
        end
    end
    
    def set_timesheet
        self.timesheet = Timesheet.find_or_create_by(job_id: self.job_id, week: self.time_in.to_datetime.cweek)
    end
    def set_employee
        self.job.employee.id = self.employee_id
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
    
    # def week_earnings
    #     hours = self.joins(:timesheet)
    #             .where(Timesheet[:id].eq(self.timesheet_id)).sum[:time_worked]
    #     ot_rate = self.pay_rate * 1.5
    #     if hours > 40
    #         reg_pay = self.pay_rate * 40
    #         ot_pay = hours - 40 * ot_rate
    #         self.earnings = reg_pay + ot_pay
    #     else
    #         self.earnings = self.pay_rate * hours
    #     end
    # end
    
    def reg_earnings
        self.earnings = self.pay_rate * self.time_worked
    end
    
    
    # def self.time_worked
    #     time = self.time_out - self.time_in
    #     time = time / 3600
    #     time.round(2)
    # end
    
    def calculate_time
        if self.time_out != nil
            time = self.time_out - self.time_in
            time = time / 3600
            self.time_worked = time.round(2)
        else
            self.time_worked = 0.00
        end
    end
    
    def update_timesheet!
        self.timesheet.update(updated_at: Time.current)
        
    end
    

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
