class ApplicationMailer < ActionMailer::Base
  default from: "bhicks@inclustaff.com"
  default to: "bhicks8364@gmail.com"
  layout 'mailer'
  # require 'mandrill'
  
  def mandrill_client
    @mandrill_client ||= Mandrill::API.new(MANDRILL_API_KEY)
  end
end
