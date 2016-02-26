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
#  state            :string           default("Pending Approval")
#
# Indexes
#
#  index_jobs_on_deleted_at    (deleted_at)
#  index_jobs_on_pay_types     (pay_types)
#  index_jobs_on_recruiter_id  (recruiter_id)
#

class Job < ActiveRecord::Base
    belongs_to :employee
    belongs_to :order, counter_cache: true
    has_many :timesheets
    has_many :shifts
    has_one :current_shift,-> { where.not(state: "Clocked Out") }, class_name: 'Shift'
    has_one :current_timesheet,-> { where(Timesheet[:week].eq(Date.today.beginning_of_week))  }, class_name: 'Timesheet'
    belongs_to :recruiter, class_name: "Admin", foreign_key: "recruiter_id"
    has_many :comments, as: :commentable
    has_many :events, as: :eventable

    delegate :user, to: :employee
    delegate :manager, to: :order
    delegate :title, to: :order
    delegate :mark_up, to: :order
    delegate :company, to: :order
    delegate :agency, to: :order
    delegate :account_manager, to: :order

    include ArelHelpers::ArelTable
    include ArelHelpers::JoinAssociation
    include Arel::Nodes


        # setup settings
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
    before_validation :defaults, :ensure_pay
    after_save :update_employee, if: :active_changed?
    # before_save :defaults

    def ensure_pay
        self.pay_rate = order.min_pay if pay_rate.nil?
    end

    # SCOPES
    scope :with_recent_comments,    -> { joins(:comments).merge(Comment.payroll_week)}
    scope :with_notes,    -> { where(NamedFunction.new("LENGTH", [Job[:description]]).gt(2))}
    scope :active, -> { where(active: true)}
    scope :with_employee, ->  { includes(:employee) }
    scope :have_ended, -> { where(Job[:end_date].not_eq(nil)) }
    scope :inactive, -> { where(active: false)}
    scope :pending_approval,      -> { where(state: "Pending Approval")}
    scope :currently_working,     -> { where(state: "Currently Working")}
    scope :ended_assignments,     -> { where(state: "Assignment Ended")}
    scope :already_working,     -> { where(state: "Already Working")}
    scope :declined_by_agency,    -> { where(state: "Declined by agency")}
    scope :declined_by_company,   -> { where(state: "Declined by company")}
    scope :declined_by_candidate, -> { where(state: "Declined by candidate")}
    scope :declined,    -> { where(state: ["Declined by agency", "Declined by company", "Declined by candidate"])}
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
    def self.without_current_shifts
        includes(:current_shift).where( :shifts => { :job_id => nil } )
    end
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
    def set_state
        update(active: false, end_date: Date.today, state: "Assignment Ended")
    end

    def mentions
        @mentions ||= begin
                        regex = /@([\w]+)/
                        description.scan(regex).flatten if description.present?
                      end
    end

    def mentioned_admins
        @mentioned_admins ||= Admin.where(username: mentions)
    end
    def requested_employees
        @requested_employees ||= User.where(last_name: mentions)
    end

    def pending_approval?; state == "Pending Approval"; end
    def currently_working?; state == "Currently Working"; end
    def declined?
        state == "Declined by agency" || state == "Declined by company" || state == "Declined by employee" || state == "Declined by other" || state == "Already Working"
    end
    def cancelled?
        state == "Assignment Ended"
    end

    def status
        if shifts.any?
            shifts.last.state
        else
            state
        end
    end
    
    def on_shift?
        # status == "Clocked In"
        shifts.clocked_in.any?
    end
    def on_break?
        shifts.on_break.any?
    end
    def off_shift?
       !shifts.clocked_in.any? && !shifts.on_break.any?
    end
    def update_employee
        currently_working? ? employee.update(assigned: true) : employee.update(assigned: false)
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

    def straight_8
        t = Time.current.beginning_of_week.midnight + 8.hours
        5.times do |n|
            time_in = t + n.days
            time_out = time_in + 8.hours
            self.shifts.create(time_in: time_in, time_out: time_out, state: "Clocked Out", out_ip: user.current_sign_in_ip)
        end
    end
    
    def forty_hour_week(week_date)
        t = week_date.beginning_of_week.midnight + 8.hours
        5.times do |n|
            time_in = t + n.days
            time_out = time_in + 8.hours
            self.shifts.create(time_in: time_in, time_out: time_out, state: "Clocked Out", out_ip: user.current_sign_in_ip)
        end
    end
    
    def same_hour_week(week_date, number)
        t = week_date.beginning_of_week.midnight + number.hours
        5.times do |n|
            time_in = t + n.days
            time_out = time_in + 8.hours
            self.shifts.create(time_in: time_in, time_out: time_out, state: "Clocked Out", out_ip: user.current_sign_in_ip)
        end
    end
    
    def name
        employee.name
    end

    def title_company
        "#{company.name} #{title} "
    end




    def defaults
        self.active = false if active.nil?
        self.active = true if state == "Currently Working"
        self.start_date = Date.today if start_date.nil?
        self.settings = {} if settings.nil?
        self.vacation = {} if vacation.nil?
        self.title = order.title  if title.nil?
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
            shifts.order(:time_in).last.time_in.stamp('Mon 11/12 at 1:05am') 
        else
            "No shifts yet."
        end
    end

    def last_clock_out
        if shifts.clocked_out.any?
            shifts.clocked_out.order(:time_out).last.time_out.stamp('Mon 11/12 at 1:05am') 
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
        CandidatePdf.new(
          id: id,
          recruiter_name: recruiter.name,
          candidate_name: employee.name,
          recruiter_email: recruiter.email,
          position_name: title,
          company_name: order.company.name,
          message: "#{recruiter.name} is presenting #{employee.name} for a position at #{company.name} ",
          company: {
            name: "#{company.name}",
            address: "#{company.address}",
            email: "#{company.contact_email}",
            logo: Rails.root.join("app/assets/images/applicants.png")
          },

          line_items: [
            ["Job Title",           title],
            ["Employee:",           employee.name],
            ["Recruiter:",          recruiter.name],
            ["Interview Notes",     description],
            ["Required Skills:",        "#{order.skills.required.order(:name).map(&:name).join(', ')}"],
            ["Other Skills:",        "#{order.skills.additional.order(:name).map(&:name).join(', ')}"],
            ["Candidate Skills:",        "#{employee.skills.order(:name).map(&:name).join(', ')}"],
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
