# == Schema Information
#
# Table name: inquiries
#
#  id           :integer          not null, primary key
#  name         :string
#  job_title    :string
#  agency_name  :string
#  email        :string
#  agency_size  :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class InquirySerializer < ActiveModel::Serializer
  attributes :id, :name, :job_title, :agency_name, :email, :agency_size, :phone_number
end
