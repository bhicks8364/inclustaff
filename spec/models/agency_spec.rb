# == Schema Information
#
# Table name: agencies
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  admin_id   :integer
#  subdomain  :string
#

require 'rails_helper'

RSpec.describe Agency, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end