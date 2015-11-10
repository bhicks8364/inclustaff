# == Schema Information
#
# Table name: jobs
#
#  id               :integer          not null, primary key
#  employee_id      :integer
#  order_id         :integer
#  title            :string
#  description      :string
#  start_date       :date
#  pay_rate         :decimal(, )
#  end_date         :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active           :boolean
#  deleted_at       :datetime
#  recruiter_id     :integer
#  timesheets_count :integer
#  settings         :hstore
#  pay_types        :text             is an Array
#

class Job < ActiveRecord::Base
    belongs_to :employee
    belongs_to :order, counter_cache: true
    has_many :timesheets
    has_many :shifts
    has_one :current_shift,-> { where.not(state: "Clocked Out") }, class_name: 'Shift'
    has_one :current_timesheet,-> { where week: Date.today.cweek  }, class_name: 'Timesheet'
    belongs_to :recruiter, class_name: "Admin", foreign_key: "recruiter_id"
    has_many :comments, as: :commentable
    
    accepts_nested_attributes_for :employee
    
    delegate :manager, to: :order
    delegate :title, to: :order
    delegate :mark_up, to: :order
    delegate :company, to: :order
    delegate :agency, to: :order
    delegate :account_manager, to: :order
    
    include ArelHelpers::ArelTable
    include ArelHelpers::JoinAssociation

    
        # setup settings
    store_accessor :settings
    
    

   
    # VALIDATIONS
    # validates_associated :employee
    validates_associated :order
    validates :employee_id,  presence: true
    validates :order_id,  presence: true
    validates :title,  presence: true, length: { maximum: 50 }
    
    # CALLBACKS
    before_validation :defaults, :set_main_pay
    after_save :update_employee
    after_create :send_notifications!
    
    
    # SCOPES
    scope :with_recent_comments,    -> { joins(:comments).merge(Comment.payroll_week)}
    # scope :with_drive_pay, -> { where("settings ? :key", :key => 'drive_pay')}
    # scope :with_ride_pay, -> { where("settings ? :key", :key => 'ride_pay')}
    # scope :with_pay, -> { where("settings ? :key", :key => 'pay_rate')}
    # scope :with_drive_pay, -> { where("settings ? :key", :key => 'drive_pay')}
    scope :active, -> { where(active: true)}
    scope :inactive, -> { where(active: false)}
    scope :with_employee, ->  { includes(:employee) }
    scope :new_start, -> { where(Job[:start_date].gteq(Date.today.beginning_of_week)) }
    
    # THESE WORKED!!!
    scope :on_shift, -> { joins(:employee).merge(Employee.on_shift)}
    scope :at_work, -> { joins(:employee).merge(Employee.at_work)}
    scope :off_shift, -> { joins(:employee).merge(Employee.off_shift)}
    scope :on_break, -> { joins(:employee).merge(Employee.on_break)}
    

    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.current_week)}
    scope :worked_today, -> { joins(:shifts).merge(Shift.in_today)}
    scope :worked_yesterday, -> { joins(:shifts).merge(Shift.in_yesterday)}
    scope :worked_this_week, -> { joins(:timesheets).where("timesheets.week <= ?", Date.today.cweek).group("jobs.id") }
    
    # MAIL - not setup yet
    def send_notifications!
        NotificationMailer.job_notification(account_manager, self).deliver_later
    end
    
    
    
    def mentions
        @mentions ||= begin
                        regex = /@([\w]+)/
                        description.scan(regex).flatten
                      end
    end
    
    def mentioned_admins
        @mentioned_admins ||= Admin.where(username: mentions)
    end
    def requested_employees
        @requested_employees ||= User.where(last_name: mentions)
    end
    
    def status
        if shifts.any?
            shifts.last.state
        else
            "No shifts yet"
        end
    end
    
    
    
    def on_shift?
        shifts.clocked_in.any?
    end
    def on_break?
        shifts.on_break.any?
    end
    def off_shift?
        if shifts.clocked_in.any?
            false
        else
            true
        end
    end
    def update_employee
        employee.mark_as_assigned!
    end

    def self.by_recuriter(admin_id)
        where(recruiter_id: admin_id)
    end
    def self.by_account_manager(admin_id)
        joins(:order).where( :orders => { :account_manager_id => admin_id } )
    end
    
    def staff
        if account_manager.present? && recruiter.present?
            "#{account_manager.last_name}  |  #{recruiter.last_name}"
        else
            "Unavailable"
        end
    end
    
  
    def name_title
        "#{employee.name} -  #{title}"
    end
    
    def set_main_pay
        pay = pay_rate
        if settings.nil?
            self.settings = {}
        end
        self.settings['pay_rate'] = pay
    end
    
    # SETS JOB TITLE TO ORDER TITLE IF THEY DIDNT CHOOSE TO CHANGE IT
    def set_job_title
        if title.nil? && order_id.present?
            job_order = Order.find(order_id)
            self.title = job_order.title
        end
    end

    def clock_in!
        if off_shift?
            self.current_shift.create(time_in: Time.current, time_out: nil,
                    state: "Clocked In",
                    out_ip: "Admin-Clock-In")
        end

    end
    
    def clock_out!
        if off_shift? && current_shift.present?
            
            self.current_shift.update(time_out: Time.current,
                        state: "Clocked Out",
                        out_ip: "Admin-Clock-Out" )
        end
    end
    
    
    def company
        order.company
    end
    
    def company_name
        order.company.name
    end
    

    def defaults
        self.active = true if active.nil?
        self.start_date = Date.today if start_date.nil?
    end
    
    def current_week_pay
        hours = shifts.current_week.sum(:time_worked)
        if hours > 40
            reg_hours = 40
            ot_hours = hours - 40
            ot_rate = pay_rate * 1.5
            pay_rate * reg_hours + ot_hours * ot_rate
        else
            pay_rate * hours
        end
    end
    
    def current_week_hours
        shifts.current_week.sum(:time_worked)
    end
    
    def hours_until_ot
        current_hours = current_week_hours
        return (40 - current_hours).round(2)
    end
    
    def approaching_overtime?
        if current_week_hours > 36
            true
        else
            false
        end
    end
    
    def total_hours
        shifts.sum(:time_worked)
    end
    
    def total_gross_pay
        hours = shifts.sum(:time_worked)
        if hours > 40
            reg_hours = 40
            ot_hours = hours - 40
            ot_rate = pay_rate * 1.5
            pay_rate * reg_hours + ot_hours * ot_rate
        else
            pay_rate * hours
        end
    end
    
    def total_gross_bill
        total_gross_pay * mark_up
    end
    
    
    

    
    def last_clock_in
        if shifts.any?
            shifts.last.time_in.strftime("%m/%e %I:%M%P")
        else
            "No shifts yet."
        end
    end
    
    def last_clock_out
        if shifts.clocked_out.any?
            shifts.clocked_out.last.time_out.strftime("%m/%e %I:%M%P")
        else
            "No complete shifts."
        end

    end
    
    def ot_rate
        (pay_rate * 1.5).round(2)
    end
    
    def bill_rate
        (pay_rate * mark_up).round(2)
    end
    
    def mark_up_percent
        (mark_up * 100 - 100).to_s + "%" 
    end

    def current_percent
        percent = (current_week_hours / 40) * 100
        if percent > 100
            100
        else
            percent
        end
    end
    private

      def remove_blanks
        self.settings = settings.reject{ |k,v| v.blank? }
      end
    
    
end
