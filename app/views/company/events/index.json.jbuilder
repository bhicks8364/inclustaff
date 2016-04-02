json.array!(@events) do |event|
  json.id event.id
  json.user_id event.user_id
  json.admin_id event.admin_id
  json.company_admin_id event.company_admin_id
  json.action event.action
  json.state event.state
  json.eventable_type event.eventable_type
  json.eventable do #event.eventable
    json.type "a #{event.eventable.class.to_s.underscore.humanize.downcase}"
  end
  json.url event_url(event, format: :json)
end
