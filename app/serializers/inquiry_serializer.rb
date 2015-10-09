class InquirySerializer < ActiveModel::Serializer
  attributes :id, :name, :job_title, :agency_name, :email, :agency_size, :phone_number
end
