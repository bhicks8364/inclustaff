json.array!(@companies) do |company|
  json.extract! company, :id, :name, :address, :state, :zipcode, :contact_name, :contact_email
  json.url company_url(company, format: :json)
end
