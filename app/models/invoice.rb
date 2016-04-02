# == Schema Information
#
# Table name: invoices
#
#  id         :integer          not null, primary key
#  company_id :integer
#  agency_id  :integer
#  due_by     :datetime
#  paid       :boolean
#  total      :decimal(, )
#  amt_paid   :decimal(, )
#  date_paid  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  week       :date
#
# Indexes
#
#  index_invoices_on_agency_id   (agency_id)
#  index_invoices_on_company_id  (company_id)
#

class Invoice < ActiveRecord::Base
    belongs_to :company
    belongs_to :agency
    has_many :timesheets
    has_many :shifts, through: :timesheets
    has_many :jobs, through: :timesheets
    has_many :orders, through: :jobs
    has_many :recruiters, through: :jobs
    has_many :account_managers, through: :orders
    has_many :comments, as: :commentable
    has_many :events, as: :eventable
    # before_save :total_amount
    before_validation :defaults
    
    validate :date_paid_cannot_be_in_the_future
 
      def date_paid_cannot_be_in_the_future
        if date_paid.present? && date_paid > Date.today
          errors.add(:date_paid, "can't be in the future")
        end
      end
    
    scope :unpaid, -> { where(paid: false)}
    scope :paid, -> { where(paid: true)}
    scope :past, -> { joins(:timesheets).merge(Timesheet.past) }
    scope :past_due, -> { unpaid.where("due_by < ?", Date.today) }
    scope :current_week, ->{ joins(:shifts).merge(Shift.current_week) }
    
    def self.by_recruiter(admin_id)
        joins(:jobs).where(jobs: { recruiter_id: admin_id })
    end
    def self.by_account_manager(admin_id)
        joins(:jobs => :orders).where( :orders => { :account_manager_id => admin_id } )
    end
    
    def recruiter
        recruiters.first
    end
    def defaults
        due = week.present? ? week : Date.today.beginning_of_week 
        self.total = 0 if total.nil?
        self.paid = false if self.paid.nil?
        self.amt_paid = 0 if self.amt_paid.nil?
        self.due_by = due + 15.days 
    end
    def self.without_timesheets
        includes(:timesheets).where( :timesheets => { :invoice_id => nil } )
    end
    def update_totals!
        amount = timesheets.sum(:total_bill)
        self.update(total: amount)
    end
    def mark_as_paid!
        self.update(paid: true, date_paid: Date.today, amt_paid: total)
    end
    def total_amount
        self.timesheets.sum(:total_bill) if self.timesheets.any?
    end
    
    def week_ending
        self.timesheets.last.week_ending
    end
    def balance
        amt = self.amt_paid || 0
        self.total - amt
    end
    def current?
        week == Date.today.beginning_of_week
    end
    def paid_on
        if date_paid.nil?
            "UNPAID"
        else
            date_paid.stamp('11/12/2015')
        end
    end
    
    def state
        if paid?
            "Paid"
        elsif current?
            "Current"
        elsif unpaid?
            "Unpaid"
        end
    end
    def unpaid?
        paid == false || nil
    end
        
    def timesheets_approved?
        if timesheets.pending.any?
           false
        else
            true
        end
    end
    def self.by_account_manager(admin_id)
        joins(:company => :orders).where(orders: { account_manager_id: admin_id })
    end
    def timesheet_data
        @t = [["Employee Name", "Total Bill"]]
            timesheets.each do |timesheet|
                timesheet_total = timesheet.total_bill ? timesheet.total_bill : 0
                @t << [timesheet.employee.name, timesheet_total]
            end
            @t
    end
    def agency_copy(view_context)
        
        InvoicePdf.new(self, agency, company, total, timesheet_data, view_context)
    end
    
    
    
    
    
end
