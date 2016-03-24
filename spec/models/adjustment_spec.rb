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

require 'rails_helper'

RSpec.describe Adjustment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
