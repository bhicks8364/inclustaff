json.array!(@company_admins) do |company_admin|

  json.name company_admin.name
  json.content company_admin.company.name

end
