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

class WorkHistorySerializer < ActiveModel::Serializer
  attributes :id, :employer_name, :start_date, :end_date, :title, :employee_id, :description, :current, :may_contact, :supervisor, :phone_number, :pay
end
