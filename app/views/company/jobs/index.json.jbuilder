json.array!(@jobs) do |job|
  json.extract! job, :id, :belongs_to, :title, :description, :start_date, :pay_rate, :end_date
  json.url job_url(job, format: :json)
end
