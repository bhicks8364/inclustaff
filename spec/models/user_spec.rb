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
