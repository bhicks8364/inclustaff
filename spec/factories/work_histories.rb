# == Schema Information
#
# Table name: work_histories
#
#  id            :integer          not null, primary key
#  employee_id   :integer          not null
#  employer_name :string
#  title         :string
#  start_date    :date
#  end_date      :date
#  description   :text
#  current       :boolean          default(FALSE)
#  may_contact   :boolean          default(FALSE)
#  supervisor    :string
#  phone_number  :string
#  pay           :string
#  pay_period    :string
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
