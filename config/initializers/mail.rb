MANDRILL_API_KEY = "jKc_zxVn9FaZYQvccZFaYw"
ActionMailer::Base.smtp_settings = {
   address: "smtp.mandrillapp.com",
   port: 587,
   authentication: "login",
   enable_starttls_auto: true,
   user_name: "bhicks8364@gmail.com",
   password: MANDRILL_API_KEY
   }
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default charset: "utf-8"
# config.action_mailer.smtp_settings = {
#   address: "smtp.gmail.com",
#   port: 587,
#   domain: "gmail.com",
#   authentication: "plain",
#   enable_starttls_auto: true,
#   user_name: "bhicks8364@gmail.com",
#   password: ENV["GMAIL_PASSWORD"]
#   }