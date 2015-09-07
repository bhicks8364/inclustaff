# == Schema Information
#
# Table name: timesheets
#
#  id           :integer          not null, primary key
#  week         :integer
#  job_id       :integer
#  reg_hours    :decimal(, )
#  ot_hours     :decimal(, )
#  gross_pay    :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#  state        :string
#  approved_by  :integer
#  shifts_count :integer
#  total_bill   :decimal(, )
#

class Timesheet < ActiveRecord::Base
    belongs_to :job, counter_cache: true
    has_many :shifts, dependent: :destroy
    has_one :employee, :through => :job
    include ArelHelpers::ArelTable
    
    
    accepts_nested_attributes_for :shifts, reject_if: :all_blank, allow_destroy: true
    
    validates_associated :shifts
    
    
    by_star_field :created_at

    delegate :mark_up, to: :job
    delegate :pay_rate, to: :job
    delegate :bill_rate, to: :job
    delegate :ot_rate, to: :job
    delegate :company, to: :job
    delegate :manager, to: :job
    delegate :recruiter, to: :job
    delegate :current_shift, to: :job
    

    before_save :total_timesheet, if: :has_a_job?
    after_initialize :defaults
    
    after_save :update_company_balance!, if: :has_a_job?
    before_create :set_job, unless: :has_a_job?
    
    def has_a_job?
        self.job.present?
    end
    
    def set_job
        self.job = self.shifts.first.job
    end
    
    # def pay_rate
    #     self.job.pay_rate
    # end
    

        
    

    scope :with_job, -> { includes(:job)}
    scope :approved, -> { where(state: "approved")}
    scope :pending, -> { where(state: "pending")}

    scope :last_week, ->{
        where(week: Date.today.cweek - 1)
    }
    scope :approaching_overtime, -> { where('reg_hours > 36') }
    scope :current_week, ->{
        where(week: Date.today.cweek)
    }
    # scope :current_week, ->{
    #     start = Time.current.beginning_of_week
    #     ending = start.end_of_week
    #     where(created_at: start..ending)
    # }
    
    def receipt
        Receipts::Receipt.new(
          id: id,
          message: "Staffing Invoice",
          company: {
            name: "IncluStaff LLC",
            address: "8364 Oberlin Rd\nElyria, OH 44035",
            email: "contact@inclustaff.com",
            logo: Rails.root.join("app/assets/images/incluStaff_logo.png")
          },
          
          line_items: [
            ["Week Ending",           week_ending],
            ["Employee", "#{job.name_title} (#{employee.code})"],
            ["Mark up",        "#{mark_up_percent}    ($#{mark_up.round(2)})"],
            ["Reg Hrs",        "#{reg_hours}    ($#{pay_rate.round(2)})"],
            ["OT Hrs",       "#{ot_hours}    ($#{ot_rate.round(2)})"],
            ["Gross Pay",         "$#{gross_pay.round(2)}"],
            ["Total Bill",         "$#{total_bill.round(2)}"],
            ["Due Date",     "#{(created_at + 14.days).strftime("%x")}"],
            ["Transaction ID", id]
          ]
        )
    end
   
    def bill_to
       company.owner
    end
       
    
    
    
    
    
    
    def self.without_shifts
        includes(:shifts).where( :shifts => { :timesheet_id => nil } )
    end
    
    
    
    def approved?
        if self.state == "approved"
            true
        else
            false
        end
    end
    def pending?
        if self.state == "pending"
            true
        else
            false
        end
    end

    def defaults
        self.state = "pending" if self.state.nil?
        self.week = Date.today.cweek if self.week.nil?
    end
    
    def total_hours
        self.reg_hours + self.ot_hours
    end
    
    
    def update_company_balance!
        self.company.set_payroll_cost!
    end
    
    def last_clock_in
        self.shifts.last.time_in
    end
    
    def last_clock_out
        if self.shifts.any?
            self.shifts.last.time_out
        end
    end
    
    def user_approved
        if self.approved?
            Admin.find(self.approved_by).name
        end
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
    def current?
        if self.week == Date.today.cweek
            true
        else 
            false
        end
    end
    
    
    
    
    
    

    
    
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
    def clocked_out?
        if self.shifts.clocked_in.any?
            false
        else
            true
        end
    end
    
    def last_clocked_in
        self.shifts.last.time_in
    end
    
    def last_clocked_out
        self.shifts.clocked_out.last.time_out
    end
    
    # def total_bill
    #     (self.gross_pay * self.mark_up).round(2)
    # end
    
    def mark_up_percent
        (self.mark_up * 100 - 100).to_i.to_s + "%" 
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
                self.total_bill = self.gross_pay * self.mark_up
                
            end
    end
    
    def week_ending
        self.shifts.last.time_in.end_of_week.strftime("%x")
    end
    
end
