# == Schema Information
#
# Table name: timesheets
#
#  id         :integer          not null, primary key
#  week       :integer
#  job_id     :integer
#  reg_hours  :decimal(, )
#  ot_hours   :decimal(, )
#  gross_pay  :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Timesheet < ActiveRecord::Base
    belongs_to :job
    has_many :shifts
    has_one :employee, :through => :job

    
    delegate :pay_rate, to: :job
    delegate :company, to: :job
    
    before_create :defaults
    before_save :total_timesheet
    
    scope :this_week, ->{
        where(week: Date.today.cweek)
    }
    scope :last_week, ->{
        where(week: Date.today.cweek - 1)
    }
    
    
    def employee_name
        self.employee.name
    end
    
    
    def defaults
        self.week = Date.today.cweek
    end
    
    def total_timesheet
        hours = self.shifts.sum(:time_worked)
            if hours > 40
                self.reg_hours = 40
                self.ot_hours = hours - 40
                ot_rate = self.pay_rate * 1.5
                self.gross_pay = self.pay_rate * self.reg_hours + self.ot_hours * ot_rate
            else
                self.reg_hours = hours
                self.ot_hours = 0
                self.gross_pay = self.pay_rate * hours
            end
    end
    
    # def current_week_pay
    #     hours = self.shifts.current_week.sum(:time_worked)
    #     if hours > 40
    #         reg_hours = 40
    #         ot_hours = hours - 40
    #         ot_rate = self.pay_rate * 1.5
    #         self.pay_rate * reg_hours + ot_hours * ot_rate
    #     else
    #         self.pay_rate * hours
    #     end
    # end
    
end
