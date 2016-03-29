# == Schema Information
#
# Table name: direct_deposits
#
#  id                :integer          not null, primary key
#  employee_id       :integer
#  account_number    :string
#  routing_number    :string
#  acct_confirmation :string
#  admin_id          :string
#  effective_date    :datetime
#  account_type      :string           default("Checking")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_direct_deposits_on_employee_id  (employee_id)
#

require 'rails_helper'

RSpec.describe "DirectDeposits", type: :request do
  describe "GET /direct_deposits" do
    it "works! (now write some real specs)" do
      get direct_deposits_path
      expect(response).to have_http_status(200)
    end
  end
end
