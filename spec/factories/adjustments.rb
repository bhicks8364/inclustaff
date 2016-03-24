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

FactoryGirl.define do
  factory :adjustment do
    timesheet_id 1
    adj_type "MyString"
    amount "9.99"
    pay_rate "9.99"
    bill_rate "9.99"
    hours "9.99"
    taxable false
    entered_by 1
  end
end
