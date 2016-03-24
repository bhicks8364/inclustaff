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
    before_save :calculate_amount
    
    
    
    def calculate_amount
        if hours > 0 
            self.amount = hours * pay_rate
        elsif amount == 0
            self.amount = pay_rate
        end
    end
    
end
