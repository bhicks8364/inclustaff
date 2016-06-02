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
#  ip_address   :string
#

class Inquiry < ActiveRecord::Base
    validates :agency_name, :name,  presence: true, length: { minimum: 5, maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX }
end
