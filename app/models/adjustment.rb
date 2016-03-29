# == Schema Information
#
# Table name: adjustments
#
#  id           :integer          not null, primary key
#  timesheet_id :integer
#  adj_type     :string
#  amount       :decimal(, )      default(0.0)
#  pay_rate     :decimal(, )
#  bill_rate    :decimal(, )
#  hours        :decimal(, )      default(0.0)
#  taxable      :boolean          default(FALSE)
#  entered_by   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bill_amount  :decimal(, )      default(0.0)
#
# Indexes
#
#  index_adjustments_on_timesheet_id  (timesheet_id)
#

class Adjustment < ActiveRecord::Base
    belongs_to :timesheet
    belongs_to :creator, class_name: "Admin", foreign_key: "entered_by"
    before_save :calculate_amount, :set_bill_amount
    
    def vacation?; adj_type == "Vacation" end;
    def bonus?; adj_type == "Bonus" end;
    def gas?; adj_type == "Gas" end;
        
    
    def set_bill_amount
        if vacation? 
            self.bill_amount = 0
            self.taxable = true
        elsif bonus?
            self.bill_amount = amount
            self.taxable = true
        elsif gas?
            self.bill_amount = amount
            self.taxable = false
        else
            self.bill_amount = amount * bill_rate
        end
    end
    def calculate_amount
        if hours > 0 
            self.amount = hours * pay_rate
            self.bill_amount = hours * bill_rate
        end
    end
    
    def updated_timesheet!
        new_bill = timesheet.total_bill + bill_amount
        new_pay = timesheet.gross_pay + amount
        timesheet.update!(gross_pay: new_pay, total_bill: new_bill)
    end
    
end
