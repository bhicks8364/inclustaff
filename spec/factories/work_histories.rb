# == Schema Information
#
# Table name: work_histories
#
#  id            :integer          not null, primary key
#  employer_name :string
#  start_date    :date
#  end_date      :date
#  title         :string
#  employee_id   :integer
#  description   :text
#  current       :boolean
#  may_contact   :boolean
#  supervisor    :string
#  phone_number  :string
#  pay           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :work_history do
    employer_name "MyString"
start_date "2015-09-28"
end_date "2015-09-28"
title "MyString"
employee_id 1
description "MyText"
current false
may_contact false
supervisor "MyString"
phone_number "MyString"
pay "MyString"
  end

end
