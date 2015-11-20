# == Schema Information
#
# Table name: invoices
#
#  id         :integer          not null, primary key
#  company_id :integer
#  agency_id  :integer
#  week       :integer
#  due_by     :datetime
#  paid       :boolean
#  total      :decimal(, )
#  amt_paid   :decimal(, )
#  date_paid  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Invoice < ActiveRecord::Base
    belongs_to :company
    belongs_to :agency
    has_many :timesheets
    # before_save :total_amount
    after_initialize :defaults
    
    # validate :date_paid_cannot_be_in_the_future
 
    #   def date_paid_cannot_be_in_the_future
    #     if date_paid.present? && date_paid > Date.today
    #       errors.add(:date_paid, "can't be in the future")
    #     end
    #   end
 
  
    
    scope :unpaid, -> { where(paid: false)}
    scope :paid, -> { where(paid: true)}
    scope :past, -> { where("week < ?", Date.today.beginning_of_week.cweek) }
    scope :past_due, -> { unpaid.where("due_by < ?", Date.today) }
    
    def defaults
       
        due = Date.today.beginning_of_week if self.new_record?
        self.total = 0 if total.nil?
        self.paid = false if self.paid.nil?
        self.amt_paid = 0 if self.amt_paid.nil?
        self.due_by = due + 15.days if due_by.nil?
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
    def paid?
        if self.paid == true
            true
        else
            false
        end
    end
    def unpaid?
        if self.paid == false
            true
        else
            false
        end
    end
    
    def paid_on
        if self.date_paid.nil?
            " "
        else
            self.date_paid.stamp('11/12/2015')
        end
    end
    
    def state
        if self.paid?
            "Paid"
        else
            "Unpaid"
        end
    end
        
    def timesheets_approved?
        if self.timesheets.pending.any?
           false
        else
            true
        end
    end
    def self.by_account_manager(admin_id)
        joins(:company => :orders).where(orders: { account_manager_id: admin_id })
    end
end
