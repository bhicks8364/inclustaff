json.array!(@events) do |event|
  json.extract! event, :id, :admin_id, :action, :eventable_id, :eventable_type
  json.url event_url(event, format: :json)
end
