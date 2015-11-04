json.array!(@shifts) do |shift|
  json.extract! shift, :id, :time_in, :time_out, :employee_id
  json.url shift_url(shift, format: :json)
end
