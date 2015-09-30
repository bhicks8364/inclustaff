json.array!(@skills) do |skill|
  json.id skill.id
  json.name skill.name
end
