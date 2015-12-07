module JobsHelper
  def stored_content
    content_for(:storage) || "<h1>Your storage is empty</h1>".html_safe
  end
  def user_email(user)
    user.email if user && user.email.present?
  end
end
