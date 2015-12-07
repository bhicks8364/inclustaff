# == Schema Information
#
# Table name: timesheets
#
#  id               :integer          not null, primary key
#  week             :integer
#  job_id           :integer
#  reg_hours        :decimal(, )
#  ot_hours         :decimal(, )
#  gross_pay        :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  state            :string
#  approved_by      :integer
#  shifts_count     :integer
#  total_bill       :decimal(, )
#  invoice_id       :integer
#  adjustments      :hstore
#  approved_by_type :string
#

class Timesheet < ActiveRecord::Base
    belongs_to :job, counter_cache: true
    belongs_to :invoice
    has_many :shifts, -> { order('time_in DESC') }, dependent: :destroy
    has_one :employee, :through => :job
    has_one :company, :through => :job
    has_one :order, :through => :job
    has_many :comments, as: :commentable
    has_many :events, as: :eventable

    has_one :recruiter, through: :job, class_name: "Admin"
    include ArelHelpers::ArelTable
    
    
    accepts_nested_attributes_for :shifts, reject_if: :all_blank, allow_destroy: true
    
    validates_associated :shifts
    


    delegate :mark_up, to: :job
    delegate :pay_rate, to: :job
    delegate :bill_rate, to: :job
    delegate :ot_rate, to: :job
    delegate :agency, to: :job
    delegate :company, to: :job
    delegate :manager, to: :job
    delegate :recruiter, to: :job
    delegate :current_shift, to: :job
    

    before_save :total_timesheet, if: :clocked_out?
    after_initialize :defaults
    
    after_save :update_company_balance!, if: :has_a_job?
    before_create :set_job, unless: :has_a_job?
    before_save :set_invoice, unless: :has_invoice?
    after_save :update_invoice!, if: :has_invoice?
    
    
    def has_a_job?
        job.present?
    end
    def has_invoice?
        invoice.present?
    end
    
    def set_job
        self.job = shifts.first.job
    end
    
    def self.by_recuriter(admin_id)
        joins(:job).where(jobs: { recruiter_id: admin_id })
    end
    

        
    
    scope :with_recent_comments,    -> { joins(:comments).merge(Comment.timesheet_comments.payroll_week)}
    scope :with_job, -> { includes(:job)}
    scope :with_shift_notes,    -> { joins(:shifts).merge(Shift.with_notes)}
    scope :approved, -> { where(state: "approved")}
    scope :pending, -> { where(state: "pending")}

    scope :last_week, ->{
        where(week: Date.today.beginning_of_week.cweek - 1)
    }
    scope :approaching_overtime, -> { where('reg_hours > 36') }
    scope :current_week, ->{ where(week: Date.today.cweek) }
    scope :past, -> { where("week < ?", Date.today.beginning_of_week.cweek) }
    
    scope :overtime_errors, -> { where('reg_hours > 40') }
    scope :needing_approval, -> { last_week.pending }
    
    
    def receipt
        Receipts::Receipt.new(
          id: id,
          message: "Weekly Pay Summary",
          company: {
            name: "#{company.agency.name}",
            address: "8364 Oberlin Rd\nElyria, OH 44035",
            email: "contact@inclustaff.com",
            logo: Rails.root.join("app/assets/images/clock.png")
          },
          
          line_items: [
            ["Week Ending",           week_ending],
            ["Assignment", "#{job.id} (#{job.title})"],
            ["Mark up",        "#{mark_up_percent}    ($#{mark_up.round(2)})"],
            ["Reg Hrs",        "#{reg_hours}    ($#{pay_rate.round(2)})"],
            ["OT Hrs",       "#{ot_hours}    ($#{ot_rate.round(2)})"],
            ["Gross Pay",         "$#{gross_pay.round(2)}"],
            
            ["Payroll ID", "#{id} - #{week}"]
          ]
        )
    end
   
    def bill_to
       company.owner
    end
       
    
    def self.by_total_bill
        order(:total_bill)
    end

    def self.without_shifts
        includes(:shifts).where( :shifts => { :timesheet_id => nil } )
    end
    def self.by_account_manager(admin_id)
        joins(:job => :order).where( :orders => { :account_manager_id => admin_id } )
    end
    
    def set_invoice
        company_id = company.id
        agency_id = company.agency.id
        invoice = Invoice.find_or_create_by(agency_id: agency_id, company_id: company_id, week: week)
        self.invoice_id = invoice.id
    end
    
    def approved?; state == "approved"; end
    def pending?; state == "pending"; end
    

    def defaults
        self.state = "pending" if state.nil?
        self.week = Date.today.cweek if week.nil?
        self.reg_hours = 0 if reg_hours.nil?
        self.ot_hours = 0 if ot_hours.nil?
    end
    
    def total_hours
        if reg_hours && ot_hours
            reg_hours + ot_hours
        elsif reg_hours
            reg_hours
        end
    end
    
    
    def update_company_balance!
        company.set_payroll_cost!
    end
    
    def update_invoice!
        invoice.update_totals!
    end
    
    def last_clock_in
        shifts.last.time_in
    end
    
    def last_clock_out
        if shifts.any?
            shifts.last.time_out
        end
    end
    
    def user_approved
        if approved? && approved_by_type == "Admin"
            Admin.find(approved_by).name
        elsif approved? && approved_by_type == "Company"
            CompanyAdmin.find(approved_by).name
        end
    end
    
   # EXPORT TO CSV
  def self.to_csv
    attributes = %w{id week company_order time_frame employee_name job_id job_title reg_hours ot_hours pay_rate ot_rate gross_pay state approved_by approved_by_type shifts_count}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      
      all.each do |timesheet|
        csv << attributes.map{ |attr| timesheet.send(attr) }
      end
    end
  end
  
    def current?
        if week == Date.today.cweek
            true
        else 
            false
        end
    end
    
    
    def company_order
        order.company_name
    end
    
    
    

    def job_title
        job.title
    end
    
    def employee_name
        employee.name
    end
    
    def clocked_in?
        if shifts.clocked_in.any?
            true
        else
            false
        end
    end
    def clocked_out?
        if shifts.clocked_in.any?
            false
        else
            true
        end
    end
    
    def last_clocked_in
        shifts.last.time_in
    end
    
    def last_clocked_out
        shifts.clocked_out.last.time_out
    end

    def mark_up_percent
        (mark_up * 100 - 100).to_i.to_s + "%" 
    end

    def total_timesheet
        if shifts.any?
            hours = shifts.sum(:time_worked)
            if hours > 40
                self.reg_hours = 40
                self.ot_hours = hours - 40
                ot_rate = job.pay_rate * 1.5
                self.gross_pay = job.pay_rate * self.reg_hours + self.ot_hours * ot_rate
            else
                pay = job.pay_rate * hours
                self.reg_hours = hours
                self.ot_hours = 0
                self.gross_pay = pay
                self.total_bill = pay * job.mark_up
                
            end
        end
    end
    
    def week_ending
        shifts.any? ? shifts.last.time_in.end_of_week.strftime("%x") : Date.today.end_of_week.strftime("%x")
    end
    def week_begin
        shifts.any? ? shifts.last.time_in.beginning_of_week.strftime("%x") : Date.today.beginning_of_week.strftime("%x")
        
    end
    def time_frame
        "#{week_begin} - #{week_ending}"
    end
    def employee_bill
        bill = total_bill || 0
        "#{employee_name} - $#{bill.round(2)}"
    end
end
