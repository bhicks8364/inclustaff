# == Schema Information
#
# Table name: company_admins
#
#  id                     :integer          not null, primary key
#  first_name             :string
#  last_name              :string
#  phone_number           :string
#  company_id             :integer
#  role                   :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  latitude               :float
#  longitude              :float
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#
# Indexes
#
#  index_company_admins_on_confirmation_token    (confirmation_token) UNIQUE
#  index_company_admins_on_email                 (email) UNIQUE
#  index_company_admins_on_invitation_token      (invitation_token) UNIQUE
#  index_company_admins_on_invitations_count     (invitations_count)
#  index_company_admins_on_invited_by_id         (invited_by_id)
#  index_company_admins_on_reset_password_token  (reset_password_token) UNIQUE
#  index_company_admins_on_unlock_token          (unlock_token) UNIQUE
#

FactoryGirl.define do
  factory :company_admin do
    
  end

end
