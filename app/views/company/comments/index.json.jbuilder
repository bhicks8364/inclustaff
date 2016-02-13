json.array!(@comments) do |comment|
  json.extract! comment, :id, :body, :commentable_id, :commentable_type, :admin_id, :read_at, :company_admin_id, :user_id, :recipient_id, :recipient_type
  json.url comment_url(comment, format: :json)
end
