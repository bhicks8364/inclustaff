json.array!(@skills) do |skill|
  json.extract! skill, :id, :name, :order_id, :required
  json.url skill_url(skill, format: :json)
end
