# == Schema Information
#
# Table name: breaks
#
#  id         :integer          not null, primary key
#  shift_id   :integer
#  time_in    :datetime
#  time_out   :datetime
#  duration   :decimal(, )
#  paid       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Break, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
