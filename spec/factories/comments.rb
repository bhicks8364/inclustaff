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
#  notify           :hstore           default({})
#
# Indexes
#
#  index_comments_on_action            (action)
#  index_comments_on_admin_id          (admin_id)
#  index_comments_on_commentable_id    (commentable_id)
#  index_comments_on_commentable_type  (commentable_type)
#  index_comments_on_company_admin_id  (company_admin_id)
#  index_comments_on_recipient_id      (recipient_id)
#  index_comments_on_recipient_type    (recipient_type)
#  index_comments_on_user_id           (user_id)
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
