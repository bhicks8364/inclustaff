# == Schema Information
#
# Table name: companies
#
#  id            :integer          not null, primary key
#  name          :string
#  address       :string
#  state         :string
#  zipcode       :string
#  contact_name  :string
#  contact_email :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  city          :string
#  balance       :decimal(, )
#  phone_number  :string
#  user_id       :integer
#  agency_id     :integer
#  admin_id      :integer
#  preferences   :hstore           default({})
#
# Indexes
#
#  index_companies_on_admin_id   (admin_id)
#  index_companies_on_agency_id  (agency_id)
#  index_companies_on_user_id    (user_id)
#

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
