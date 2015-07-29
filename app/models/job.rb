# == Schema Information
#
# Table name: jobs
#
#  id          :integer          not null, primary key
#  employee_id :integer
#  order_id    :integer
#  title       :string
#  description :string
#  start_date  :date
#  pay_rate    :decimal(, )
#  end_date    :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active      :boolean
#

class Job < ActiveRecord::Base
    belongs_to :employee
    belongs_to :order
    has_many :timesheets
    has_many :shifts, inverse_of: :job
    has_many :timesheets
    has_one :current_shift,-> { where state: "clocked_in" }, class_name: 'Shift'
    
    accepts_nested_attributes_for :employee
    
    include ArelHelpers::ArelTable
    
    # VALIDATIONS
    # validates_associated :employee
    validates_associated :order
    # validates :employee_id,  presence: true
    validates :order_id,  presence: true
    validates :title,  presence: true, length: { maximum: 50 }
    
    # CALLBACKS
    after_initialize :defaults

    # SCOPES
    scope :active, -> { where(active: true)}
    scope :inactive, -> { where(active: false)}
    scope :with_employee, ->  { includes(:employee) }
    scope :on_shift, -> { joins(:shifts).merge(Shift.clocked_in)}
    scope :worked_today, -> { joins(:shifts).merge(Shift.in_today)}
    scope :worked_yesterday, -> { joins(:shifts).merge(Shift.in_yesterday)}
    scope :worked_last_week, -> { joins(:timesheets).where("timesheets.week <= ?", Date.today.cweek).group("jobs.id") }

    
    
    def company
        self.order.company
    end
    
    def company_name
        self.order.company.name
    end
    

    def defaults
        self.active = true if self.active.nil?
    end
    
    def current_week_pay
        hours = self.shifts.current_week.sum(:time_worked)
        if hours > 40
            reg_hours = 40
            ot_hours = hours - 40
            ot_rate = self.pay_rate * 1.5
            self.pay_rate * reg_hours + ot_hours * ot_rate
        else
            self.pay_rate * hours
        end
    end
    
    def current_week_hours
        self.shifts.current_week.sum(:time_worked)
    end
    
    def total_hours
        self.shifts.sum(:time_worked)
    end
    
    def total_gross_pay
        hours = self.shifts.sum(:time_worked)
        if hours > 40
            reg_hours = 40
            ot_hours = hours - 40
            ot_rate = self.pay_rate * 1.5
            self.pay_rate * reg_hours + ot_hours * ot_rate
        else
            self.pay_rate * hours
        end
    end
    
    def on_shift?
        self.shifts.clocked_in.any?
    end
    
    def last_clock_in
        self.shifts.last.time_in
    end
    
    def last_clock_out
        if self.shifts.any?
            self.shifts.last.time_out
        end
    end
    
    def current_timesheet
        self.timesheets.this_week.first
    end
    
    
    
end
