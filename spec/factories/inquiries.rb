# == Schema Information
#
# Table name: inquiries
#
#  id           :integer          not null, primary key
#  name         :string
#  job_title    :string
#  agency_name  :string
#  email        :string
#  agency_size  :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  ip_address   :string
#

FactoryGirl.define do
  factory :inquiry do
    name "MyString"
job_title "MyString"
agency_name "MyString"
email "MyString"
agency_size "MyString"
phone_number "MyString"
  end

end
