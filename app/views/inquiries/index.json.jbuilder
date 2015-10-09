json.array!(@inquiries) do |inquiry|
  json.extract! inquiry, :id, :name, :job_title, :agency_name, :email, :agency_size, :phone_number
  json.url inquiry_url(inquiry, format: :json)
end
