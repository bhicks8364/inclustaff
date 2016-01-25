json.array!(@admins) do |admin|
  json.id admin.id
  json.name admin.name
end
