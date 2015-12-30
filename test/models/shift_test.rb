# == Schema Information
#
# Table name: shifts
#
#  id             :integer          not null, primary key
#  time_in        :datetime
#  time_out       :datetime
#  employee_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_worked    :decimal(, )
#  job_id         :integer
#  state          :string
#  earnings       :decimal(, )
#  timesheet_id   :integer
#  deleted_at     :datetime
#  in_ip          :string
#  out_ip         :string
#  week           :integer
#  note           :text
#  needs_adj      :boolean
#  break_duration :decimal(, )
#  breaks         :text             is an Array
#  break_in       :datetime         is an Array
#  break_out      :datetime         is an Array
#  paid_breaks    :boolean          default(FALSE)
#  pay_rate       :decimal(, )
#  latitude       :float
#  longitude      :float
#

require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
