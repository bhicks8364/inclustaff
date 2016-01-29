# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  admin_id         :integer
#  action           :string
#  eventable_id     :integer
#  eventable_type   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  agency_id        :integer
#  company_admin_id :integer
#  read_at          :datetime
#
# Indexes
#
#  index_events_on_agency_id         (agency_id)
#  index_events_on_company_admin_id  (company_admin_id)
#  index_events_on_user_id           (user_id)
#

FactoryGirl.define do
  factory :event do
  admin_id 1
  action "MyString"
  eventable_id 1
  eventable_type "MyString"
  end

end
