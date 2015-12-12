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
#

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(agency_id: 1, role: "Employee", first_name: "Andy", last_name: "Lindeman",
    email: 'andy@email.com', password: generated_password, password_confirmation: generated_password) }
  # it "orders by last name" do
  #   generated_password = Devise.friendly_token.first(8)
    
  #   chelimsky = User.create(agency_id: 1, role: "Employee", first_name: "David", last_name: "Chelimsky",
  #   email: 'david@email.com', password: generated_password, password_confirmation: generated_password)

  #   expect(User.ordered_by_last_name.pluck(:last_name)).to eq(["Chelimsky", "Lindeman"])
  # end
  it 'creates an employee if it doesnt have one' do
    
    user.set_employee
      expect(user.assigned?).to eq(false)
  end
  
end
