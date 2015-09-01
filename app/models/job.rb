# == Schema Information
#
# Table name: jobs
#
#  id           :integer          not null, primary key
#  employee_id  :integer
#  order_id     :integer
#  title        :string
#  description  :string
#  start_date   :date
#  pay_rate     :decimal(, )
#  end_date     :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  active       :boolean
#  deleted_at   :datetime
#  recruiter_id :integer
#

class Job < ActiveRecord::Base
    belongs_to :employee
    belongs_to :order
    has_many :timesheets
    has_many :shifts, inverse_of: :job
    has_one :current_shift,-> { where state: "Clocked In" }, class_name: 'Shift'
    has_one :current_timesheet,-> { where week: Date.today.cweek  }, class_name: 'Timesheet'
    belongs_to :recruiter, class_name: "Admin", foreign_key: "recruiter_id"

    
    accepts_nested_attributes_for :employee
    
    delegate :manager, to: :order
    delegate :company, to: :order
    
    include ArelHelpers::ArelTable
    
    # VALIDATIONS
    # validates_associated :employee
    validates_associated :order
    # validates :employee_id,  presence: true
    # validates :order_id,  presence: true
    validates :title,  presence: true, length: { maximum: 50 }
    
    # CALLBACKS
    after_initialize :defaults

    # SCOPES
    scope :active, -> { where(active: true)}
    scope :inactive, -> { where(active: false)}
    scope :with_employee, ->  { includes(:employee) }
    scope :on_shift, -> { joins(:shifts).merge(Shift.clocked_in)}
    scope :off_shift, -> { joins(:employee).merge(Employee.off_shift)}
    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.this_week)}
    scope :worked_today, -> { joins(:shifts).merge(Shift.in_today)}
    scope :worked_yesterday, -> { joins(:shifts).merge(Shift.in_yesterday)}
    scope :worked_last_week, -> { joins(:timesheets).where("timesheets.week <= ?", Date.today.cweek).group("jobs.id") }
    
    
    
    def on_shift?
        self.shifts.clocked_in.any?
    end
    def off_shift?
        if self.shifts.clocked_in.any?
            false
        else
            true
        end
    end
    
    def self.by_recuriter(admin_id)
        where(recruiter_id: admin_id)
    end
    
    def staff
        if manager.present? && recruiter.present?
            "#{manager.role}: #{manager.name} | #{recruiter.role}: #{recruiter.name}"
        else
            "#{company.owner.role}: #{company.owner.name}"
        end
    end
    
    def name_title
        "#{employee.name} -  #{title}"
    end
    
    # def clock_in(job)
    #     if job.off_shift?
    #         job.build_current_shift(time_in: Time.current, time_out: nil,
    #                 state: "Clocked In", in_ip: self.employee.current_sign_in_ip,
    #                 out_ip: nil)
    #     end
    # end
    def clock_in!
        if self.off_shift?
            self.shifts.create(time_in: Time.current, time_out: nil,
                    state: "Clocked In",
                    out_ip: nil)
        end
        # self.update(time_in: Time.current, time_out: nil,
        #             state: "Clocked In",
        #             out_ip: nil)
    end
        

    
    
    def company
        self.order.company
    end
    
    def company_name
        self.order.company.name
    end
    

    def defaults
        self.active = true if self.active.nil?
        self.start_date = Date.today if self.start_date.nil?
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
    
    def hours_until_ot
        current_hours = self.current_week_hours
        return (40 - current_hours).round(2)
    end
    
    def approaching_overtime?
        if self.current_week_hours > 36
            true
        else
            false
        end
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
    

    
    def last_clock_in
        self.shifts.last.time_in
    end
    
    def last_clock_out
        if self.shifts.any?
            self.shifts.last.time_out
        end
    end
    

    def current_percent
        percent = (self.current_week_hours / 40) * 100
        if percent > 100
            100
        else
            percent
        end
    end
    
    
    
end
