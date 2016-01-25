# == Schema Information
#
# Table name: admins
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
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  company_id             :integer
#  role                   :string
#  username               :string
#  agency_id              :integer
#  name                   :string
#  latitude               :float
#  longitude              :float
#

FactoryGirl.define do
  factory :admin do
    first_name = "Brittany"
		last_name = "Hicks"
		email = "bhicks@email.com"
		agency_id = 1
		role = "Owner"
		#encrypted_password = Admin.new(:password => password).encrypted_password
		sign_in_count = 0
		failed_attempts = 0
  end

end
