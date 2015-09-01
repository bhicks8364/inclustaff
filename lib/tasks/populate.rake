namespace :db do
	
  desc "Create 10 companies with random names and addresses"
  task :populate => :environment do
	require 'populator'
	require 'ffaker'
	  Company.populate 10 do |company|
		company.name = FFaker::Company.name
		company.city = FFaker::Address.city
		company.state = FFaker::AddressUS.state
		company.zipcode = FFaker::AddressUS.zip_code
		company.address = FFaker::AddressUS.street_address
		company.phone_number = FFaker::PhoneNumber.phone_number
		puts company.name
	  end
	  puts 'All done!!!'
  end
  
  desc "Create 25 employees with random names and descriptions"
  task :pop_emp => :environment do
	require 'populator'
	require 'ffaker'
	password = "password"
	  User.populate 25 do |user|
		user.first_name = FFaker::Name.first_name
		user.last_name = FFaker::Name.last_name
		user.email = FFaker::Internet.email
		user.city = FFaker::Address.city
		user.state = FFaker::AddressUS.state
		user.zipcode = FFaker::AddressUS.zip_code
		user.address = FFaker::AddressUS.street_address
		user.role = "Employee"
		user.encrypted_password = User.new(:password => password).encrypted_password
		user.sign_in_count = 0
		


		
		puts user.first_name
	  end
	  puts 'All done!!!'
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
end



# require "as-duration"
# FFaker::Time.between(2.days.ago, Time.now, :all) #=> "2014-09-19 07:03:30 -0700"
# FFaker::Time.between(2.days.ago, Time.now, :day) #=> "2014-09-18 16:28:13 -0700"
# FFaker::Time.between(2.days.ago, Time.now, :night) #=> "2014-09-20 19:39:38 -0700"
# FFaker::Time.between(2.days.ago, Time.now, :morning) #=> "2014-09-19 08:07:52 -0700"
# FFaker::Time.between(2.days.ago, Time.now, :afternoon) #=> "2014-09-18 12:10:34 -0700"
# FFaker::Time.between(2.days.ago, Time.now, :evening) #=> "2014-09-19 20:21:03 -0700"
# FFaker::Time.between(2.days.ago, Time.now, :midnight) #=> "2014-09-20 00:40:14 -0700"