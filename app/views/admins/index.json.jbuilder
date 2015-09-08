json.array!(@admins) do |admin|
  json.id admin.id
  json.name admin.username
end
