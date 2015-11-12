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
#  dns              :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe Employee, type: :model do

    context "new employee" do
        it 'is invalid without user_id' do
            emp1 = Employee.new
            expect(emp1).to_not be_valid
        end
    end

end
