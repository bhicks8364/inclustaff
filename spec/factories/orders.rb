
# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  company_id    :integer
#  pay_range     :string
#  notes         :text
#  number_needed :integer
#  needed_by     :datetime
#  urgent        :boolean
#  active        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string
#  deleted_at    :datetime
#  manager_id    :integer
#
