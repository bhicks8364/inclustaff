# == Schema Information
#
# Table name: employees
#
#  id               :integer          not null, primary key
#  first_name       :string
#  last_name        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  email            :string
#  ssn              :string
#  phone_number     :string
#  user_id          :integer
#  deleted_at       :datetime
#  assigned         :boolean
#  resume_id        :string
#  desired_job_type :string
#  desired_shift    :string
#  availablity      :hstore
#

require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
