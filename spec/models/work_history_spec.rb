# == Schema Information
#
# Table name: work_histories
#
#  id            :integer          not null, primary key
#  employer_name :string
#  start_date    :date
#  end_date      :date
#  title         :string
#  employee_id   :integer
#  description   :text
#  current       :boolean
#  may_contact   :boolean
#  supervisor    :string
#  phone_number  :string
#  pay           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe WorkHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
