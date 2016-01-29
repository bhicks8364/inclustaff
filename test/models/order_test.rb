# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  notes                     :text
#  number_needed             :integer
#  needed_by                 :datetime
#  urgent                    :boolean
#  active                    :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  title                     :string
#  deleted_at                :datetime
#  manager_id                :integer
#  jobs_count                :integer
#  account_manager_id        :integer
#  mark_up                   :decimal(, )
#  agency_id                 :integer
#  dt_req                    :string
#  bg_check                  :string
#  heavy_lifting             :boolean
#  stwb                      :boolean
#  est_duration              :string
#  shift                     :string
#  bwc_code                  :string
#  min_pay                   :decimal(, )
#  max_pay                   :decimal(, )
#  pay_frequency             :string
#  address                   :string
#  latitude                  :float
#  longitude                 :float
#  aca_type                  :string
#  education                 :hstore           default({})
#  requirements              :hstore           default({})
#  industry                  :string
#  published_at              :datetime
#  published_by              :integer
#  expires_at                :datetime
#  mobile_time_clock_enabled :boolean          default(FALSE)
#
# Indexes
#
#  index_orders_on_account_manager_id  (account_manager_id)
#  index_orders_on_agency_id           (agency_id)
#  index_orders_on_deleted_at          (deleted_at)
#  index_orders_on_industry            (industry)
#  index_orders_on_manager_id          (manager_id)
#  index_orders_on_published_by        (published_by)
#

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
