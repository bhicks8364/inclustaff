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
#  deleted_at :datetime
#

class Timesheet < ActiveRecord::Base
    belongs_to :job, dependent: :destroy
    has_many :shifts, dependent: :destroy
    has_one :employee, :through => :job
    
    by_star_field :created_at

    
    delegate :pay_rate, to: :job
    delegate :company, to: :job
    delegate :manager, to: :job
    

    before_save :total_timesheet
    

    scope :with_job, -> { includes(:job)}
    scope :this_week, ->{
        where(week: Date.today.cweek)
    }
    scope :last_week, ->{
        where(week: Date.today.cweek - 1)
    }
    
    after_save :update_company_balance!
    
    def update_company_balance!
        self.company.set_payroll_cost!
    end
    
    
    
    #       # EXPORT TO CSV
    #   def self.assign_from_row(row)
    #     # user = User.where(email: row[:email]).first_or_initialize
    #     timesheet = Timesheet.new row.to_hash.slice(:first_name, :last_name, :email, :profile_type, :role)
    #     user
    #   end
      
    #   def self.to_csv
    #     attributes = %w{id last_name first_name email profile_type role}
    #     CSV.generate(headers: true) do |csv|
    #       csv << attributes
          
    #       all.each do |user|
    #         csv << user.attributes.values_at(*attributes)
    #       end
    #     end
    #   end
    
    
    
    
    
    
    

    
    
    def employee_name
        self.employee.name
    end
    
    def clocked_in?
        if self.shifts.clocked_in.any?
            true
        else
            false
        end
    end
    
    def last_clocked_in
        self.shifts.last.time_in
    end
    
    def last_clocked_out
        self.shifts.clocked_out.last.time_out
    end
    
    
    # def defaults
    #     self.week = Date.today.cweek
    # end
    
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
    
    def week_ending
        self.shifts.last.time_out.end_of_week.strftime("%x")
    end
    
end
