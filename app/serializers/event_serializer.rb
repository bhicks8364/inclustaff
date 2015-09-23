# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  admin_id       :integer
#  action         :string
#  eventable_id   :integer
#  eventable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#

class EventSerializer < ActiveModel::Serializer
  attributes :id, :admin_id, :action, :eventable_id, :eventable_type
end
