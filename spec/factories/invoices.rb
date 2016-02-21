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

FactoryGirl.define do
  factory :invoice do
    company_id 1
agency_id 1
week 1
due_by "2015-10-06 21:22:17"
paid false
total "9.99"
amt_paid "9.99"
date_paid "2015-10-06 21:22:17"
  end

end
