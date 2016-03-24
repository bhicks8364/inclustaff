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
#  availability     :hstore
#  dns              :boolean          default(FALSE)
#  exsisting_hours  :decimal(, )      default(0.0)
#  aca_hours        :decimal(, )      default(0.0)
#  status           :string           default("New")
#
# Indexes
#
#  index_employees_on_availability  (availability)
#  index_employees_on_deleted_at    (deleted_at)
#  index_employees_on_email         (email)
#  index_employees_on_user_id       (user_id)
#

require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
