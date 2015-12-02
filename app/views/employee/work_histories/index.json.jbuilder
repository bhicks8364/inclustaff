json.array!(@work_histories) do |work_history|
  json.extract! work_history, :id, :employer_name, :start_date, :end_date, :title, :employee_id, :description, :current, :may_contact, :supervisor, :phone_number, :pay
  json.url work_history_url(work_history, format: :json)
end
