# == Schema Information
#
# Table name: shifts
#
#  id          :integer          not null, primary key
#  time_in     :datetime
#  time_out    :datetime
#  employee_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  time_worked :decimal(, )
#  company_id  :integer
#  job_id      :integer
#  state       :string
#

class Shift < ActiveRecord::Base
    extend SimpleCalendar
    has_calendar :attribute => :time_in
    
    belongs_to :employee, inverse_of: :shifts
    belongs_to :job, inverse_of: :shifts
    belongs_to :company, class_name: "Company", foreign_key: "company_id"

    # has_one :order, through: :job
    # has_one :company, through: :order
    
    validates_associated :employee
    validates_associated :job
    validates :time_in, presence: true
    
    delegate :pay_rate, to: :job
    
    accepts_nested_attributes_for :job
    
    before_save :calculate_time!
    # before_create :set_company
    
    # SCOPES
    scope :payroll_week, ->{
        start = Time.zone.now.beginning_of_week
        ending = start.end_of_week + 7.days
        where(time_in: start..ending)
    }
    scope :current_week, ->{
        start = Time.zone.now.beginning_of_week
        ending = start.end_of_week
        where(time_in: start..ending)
    }
    
    
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
        time = self.time_out - self.time_in
        time = time / 3600
        self.time_worked = time.round(2)
    end
    
    # def set_company
        # self.job.company.id = self.company_id
    # end
        
    
    
end
