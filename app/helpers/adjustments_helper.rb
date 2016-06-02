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


module AdjustmentsHelper
    def is_taxable?(adj)
        if adj.taxable?
            "<i class='fa fa-dollar green' data-toggle='tooltip'  title='Taxable'></i>".html_safe
        else
            "<i class='fa fa-dollar' data-toggle='tooltip'  title='Non-taxable'></i>".html_safe
        end
    end
        
end
