# == Schema Information
#
# Table name: breaks
#
#  id         :integer          not null, primary key
#  shift_id   :integer
#  time_in    :datetime
#  time_out   :datetime
#  duration   :decimal(, )
#  paid       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :break do
    shift_id 1
clock_in "2016-01-29 12:05:39"
clock_out "2016-01-29 12:05:39"
duration "9.99"
paid false
  end

end
