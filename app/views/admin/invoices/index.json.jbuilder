json.array!(@invoices) do |invoice|
  json.extract! invoice, :id, :company_id, :agency_id, :week, :due_by, :paid, :total, :amt_paid, :date_paid
  json.url invoice_url(invoice, format: :json)
end
