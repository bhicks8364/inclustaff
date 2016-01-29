# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :string
#  first_name             :string
#  last_name              :string
#  deleted_at             :datetime
#  can_edit               :boolean
#  code                   :string
#  address                :string
#  city                   :string
#  state                  :string
#  zipcode                :string
#  employee_id            :integer
#  agency_id              :integer
#  resume_id              :integer
#  checked_in_at          :datetime
#  name                   :string
#  latitude               :float
#  longitude              :float
#  start_date             :date
#
# Indexes
#
#  index_users_on_agency_id             (agency_id)
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_resume_id             (resume_id)
#  index_users_on_role                  (role)
#

require "rails_helper"

describe User, type: :model do
  before do
    @user = User.create!(agency_id: 1, first_name: "Test", last_name: "User", email: "test@user.com", password: "password", password_confirmation: "password")
    @employee = @user.create_employee
  end

  it "calculates the ACA hours worked" do
    @employee.shifts.create(pay_rate: 10, time_in: 3.hours.ago, time_out: 1.hour.ago)
    expect(@employee.aca_hours_worked).to eq(2)
  end

end
