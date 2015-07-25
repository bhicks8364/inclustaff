json.array!(@orders) do |order|
  json.extract! order, :id, :belong_to, :pay_range, :notes, :number_needed, :needed_by, :urgent, :active
  json.url order_url(order, format: :json)
end
