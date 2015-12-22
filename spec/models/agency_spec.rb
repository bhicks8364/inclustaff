# == Schema Information
#
# Table name: public.agencies
#
#  id            :integer          not null, primary key
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_id      :integer
#  subdomain     :string
#  address       :string
#  city          :string
#  state         :string
#  zipcode       :string
#  phone_number  :string
#  free_trial    :boolean
#  contact_name  :string
#  contact_email :string
#  contact_id    :integer
#  logo_url      :string
#

require 'rails_helper'

RSpec.describe Agency, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
