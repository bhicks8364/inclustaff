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
#  vacation         :hstore
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
    has_many :events, as: :eventable
    
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
    store_accessor :settings, :drive_pay, :ride_pay
    store_accessor :vacation, :number_of_days, :milestone_1, :milestone_2, :milestone_3

    # VALIDATIONS
    # validates_associated :employee
    validates_associated :order
    validates :employee_id,  presence: true
    validates :pay_rate,  presence: true
    validates :order_id,  presence: true
    validates :title,  presence: true, length: { maximum: 50 }
    
    # CALLBACKS
    # after_create :send_notifications!
    before_validation :defaults, :set_main_pay
    after_save :update_employee
    after_initialize :ensure_pay
    def ensure_pay
        self.pay_rate = order.min_pay if pay_rate.nil?
    end
    
    
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
    scope :on_shift, -> { joins(:shifts).merge(Shift.clocked_in)}
    scope :at_work, -> { joins(:shifts).merge(Shift.at_work)}
    scope :off_shift, -> { joins(:shifts).merge(Shift.clocked_out)}
    scope :on_break, -> { joins(:shifts).merge(Shift.on_break)}
    

    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.current_week)}
    scope :worked_today, -> { joins(:shifts).merge(Shift.in_today)}
    scope :worked_yesterday, -> { joins(:shifts).merge(Shift.in_yesterday)}
    scope :worked_this_week, -> { joins(:timesheets).where("timesheets.week <= ?", Date.today.cweek).group("jobs.id") }
    
    # MAIL - not setup yet
    def send_notifications!
        NotificationMailer.job_notification(account_manager, self).deliver_later
    end
    
    def hours_until_vacation
        if vacation['milestone_1'].to_i > total_hours
            (vacation['milestone_1'].to_i - total_hours).round(2)
        elsif vacation['milestone_2'].to_i > total_hours
            (vacation['milestone_2'].to_i - total_hours).round(2)
        elsif vacation['milestone_3'].to_i > total_hours
            (vacation['milestone_3'].to_i - total_hours).round(2)
        end
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
        shifts.any? ? shifts.last.state : "No shifts yet"
    end

    
    def on_shift?
        # status == "Clocked In"
        shifts.clocked_in.any?
    end
    def on_break?
        shifts.on_break.any?
    end
    def off_shift?
       !shifts.clocked_in.any?
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
    # pretty sure theres a better way to do this to. In the controller mayber?
    def set_job_title
        if title.nil? && order_id.present?
            job_order = Order.find(order_id)
            self.title = job_order.title
        end
    end

    def clock_in!
        if off_shift?
            self.shifts.create(time_in: Time.current, time_out: nil,
                    state: "Clocked In",
                    out_ip: "Admin-Clock-In")
        end

    end
    
    def clock_out!
        if on_shift? 
            current_shift.update(time_out: Time.current,
                        state: "Clocked Out",
                        out_ip: "Admin-Clock-Out" )
        end
    end
    
    def straight_8
        t = Time.current.beginning_of_week - 1.week 
        
        5.times do |n| 
            time_in = t + n.days
            time_out = time_in + 8.hours
         self.shifts.create(time_in: time_in, time_out: time_out, state: "Clocked Out", out_ip: "Admin-Clock-Out") 
        
        end 
    
    end
    
    
    def company
        order.company
    end
    
    def title_company
        "#{company.name} #{title} "
    end
    

    def defaults
        self.active = true if active.nil?
        self.start_date = Date.today if start_date.nil?
        self.settings = {} if settings.nil?
        self.vacation = {} if vacation.nil?
    end
    
    
    def current_week_pay
        
        if shifts.current_week.any?
            hours = shifts.current_week.sum(:time_worked)
            if hours > 40
                reg_hours = 40
                ot_hours = hours - 40
                ot_rate = pay_rate * 1.5
                pay_rate * reg_hours + ot_hours * ot_rate
            else
                pay_rate * hours
            end
        else
            0.00
        end
        
    end
    
    def current_week_hours
        if shifts.current_week.any?
            shifts.current_week.sum(:time_worked)
        else
            0.00
        end
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
    def first_day
        if shifts.any?
            shifts.first.time_in
        else
            start_date
        end
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
            shifts.last.time_in.stamp('11/12/2015 at 1:05am')
        else
            "No shifts yet."
        end
    end
    
    def last_clock_out
        if shifts.clocked_out.any?
            shifts.clocked_out.last.time_out.stamp('11/12/2015 at 1:05am')
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
    def candidate_sheet
        Receipts::Receipt.new(
          id: id,
          message: "Candidate Sheet: #{employee.name} - #{title_company}",
          company: {
            name: "#{company.name}",
            address: "#{company.address}",
            email: "#{company.contact_email}",
            logo: Rails.root.join("app/assets/images/user-profile-1.png")
          },
          
          line_items: [
            ["Job Title",           title],
            ["Employee:",           employee.name],
            ["Recruiter:",          recruiter.name],
            ["Interview Notes",     description],
            ["Required Skills:",        "#{order.skills.required.order(:name).map(&:name).join(', ')}"],
            ["Other Skills:",        "#{order.skills.additional.order(:name).map(&:name).join(', ')}"],
            ["Candidate Skills:",        "#{employee.skills.order(:name).map(&:name).join(', ')}"],
            ["Job Description:",      order.notes],
            ["Needed By",         order.needed_by.stamp('11/12/2015')],
            ["Pay - Bill",         "$#{pay_rate.round(2)}  -  $#{bill_rate.round(2)}"],
            ["Mark Up",         mark_up_percent],
            ["Start Date",         start_date.stamp('11/12/2015')]
          ]
        )
    end
    private

      def remove_blanks
        self.settings = settings.reject{ |k,v| v.blank? }
      end
    
    
end
