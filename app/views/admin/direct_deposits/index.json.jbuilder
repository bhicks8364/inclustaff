json.array!(@direct_deposits) do |direct_deposit|
  json.extract! direct_deposit, :id, :employee_id, :account_number, :routing_number, :acct_confirmation, :admin_id, :effective_date, :account_type
  json.url direct_deposit_url(direct_deposit, format: :json)
end
