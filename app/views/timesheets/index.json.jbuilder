json.array!(@timesheets) do |timesheet|
  json.extract! timesheet, :id, :week, :job_id, :reg_hours, :ot_hours, :gross_pay
  json.url timesheet_url(timesheet, format: :json)
end
