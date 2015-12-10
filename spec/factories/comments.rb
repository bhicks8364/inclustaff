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
#  action           :string
#  recipient_id     :integer
#  recipient_type   :string
#  alert            :boolean
#  read_at          :datetime
#

FactoryGirl.define do
  factory :comment do
    commentable_type "MyString"
commentable_id 1
admin_id 1
company_admin_id 1
user_id 1
body "MyText"
  end

end
