# == Schema Information
#
# Table name: direct_deposits
#
#  id                :integer          not null, primary key
#  employee_id       :integer
#  account_number    :string
#  routing_number    :string
#  acct_confirmation :string
#  admin_id          :string
#  effective_date    :datetime
#  account_type      :string           default("Checking")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_direct_deposits_on_employee_id  (employee_id)
#

FactoryGirl.define do
  factory :direct_deposit do
    employee_id 1
    account_number "MyString"
    routing_number "MyString"
    acct_confirmation "MyString"
    admin_id "MyString"
    effective_date "2016-03-26 03:13:15"
    account_type "MyString"
  end
end
