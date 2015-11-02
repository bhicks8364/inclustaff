# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string
#  commentable_id   :integer
#  admin_id         :integer
#  company_admin_id :integer
#  user_id          :integer
#  body             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
    belongs_to :user
    belongs_to :admin
    belongs_to :company_admin
    scope :today,         -> {where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }
end
