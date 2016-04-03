namespace :db do
	
  desc "Create 10 companies with random names and addresses"
  task :populate => :environment do
	require 'populator'
	require 'ffaker'
	require 'faker'
		def range (min, max)
	    	rand * (max-min) + min
		end
		Apartment::Tenant.switch!('demoo')
		Company.populate 3 do |company|
			company.name = FFaker::Company.name
			company.city = FFaker::Address.city
			company.state = FFaker::AddressUS.state
			company.zipcode = FFaker::AddressUS.zip_code
			company.address = FFaker::AddressUS.street_address
			company.phone_number = FFaker::PhoneNumber.phone_number
			company.agency_id = 3
			company.contact_name = Faker::Name.name
			company.contact_email = Faker::Internet.safe_email
			# Order.populate(1...3) do |order|
			# 	order.company_id = company.id
			# 	order.agency_id = 3
			# 	order.needed_by = Faker::Date.forward(14)
			# 	order.title = FFaker::Company.position
			# 	order.notes = FFaker::HealthcareIpsum.paragraph
			# 	order.number_needed = 1..4
			# 	order.pay_range = [ "$8.10 - $10.00","$10.00 - $12.00","$12.00 - $15.00", "$15.00 - $18.00", "$18.00 - $22.00", "$22.00 +  "]
			# 	order.est_duration = [ "Temp-to-Hire", "Direct-Hire", "Temporary"]
			# 	order.dt_req = [ "None Required", "Yes - 5 panel screen", "Yes - 10 panel screen"]
			# 	order.bg_check = [ "None Required", "Yes - No Felonies", "Yes - Case by case"]
			# 	order.shift = [ "1st shift", "2nd shift", "3rd shift", "Flexible"]
			# 	order.stwb = [true, false]
			# 	order.heavy_lifting = [true, false]
			# 	order.active = true
			# 	order.urgent =  [true, false]
			# end
			
		end
	  puts 'All done!!!'
  end
  
  desc "Create random shifts"
  task :pop_shifts => :environment do
	require 'populator'
	require 'ffaker'
	require 'faker'
	# require "as-duration"
	# def random_hour(from, to)
 # 		(Date.today + 1.hour + rand(0..60).minutes).to_datetime
	# end
	Apartment::Tenant.switch!('testing')
	[Company, Order, User].each(&:delete_all)
    
    Company.populate 20 do |company|
      company.name = Faker::Company.name
      company.name = Populator.words(1..3).titleize
      Order.populate 10..100 do |order|
      	time = (2.years.ago..Time.now)
        order.company_id = company.id
        order.title = Populator.words(1..4).titleize
        order.notes = Populator.sentences(2..10)
        order.min_pay = 9...30
        order.max_pay = order.min_pay + 1..3
        order.bg_check = ["None", "Case-by-case", "No Felonies"]
        order.dt_req = ["None", "Yes - 5 panel", "Yes - 10 panel"]
        order.heavy_lifting = [true, false]
        order.stwb = [true, false]
        order.created_at = time
        order.needed_by = time + 2.weeks
        order.shift = [ "1st shift", "2nd shift", "3rd shift", "Flexible"]
      end
    end
	    
    User.populate 50 do |user|
	  	user.agency_id = 3
		user.first_name = FFaker::Name.first_name
		user.last_name = FFaker::Name.last_name
		user.email = FFaker::Internet.free_email
		user.city = FFaker::Address.city
		user.state = FFaker::AddressUS.state
		user.zipcode = FFaker::AddressUS.zip_code
		user.address = FFaker::AddressUS.street_address
		user.role = "Employee"
		user.encrypted_password = User.new(:password => password).encrypted_password
		user.sign_in_count = 0
		Employee.populate 1 do |employee|
			employee.user_id = user.id
			employee.first_name = user.first_name
			employee.last_name = user.last_name
			employee.email = user.email
			employee.ssn = 1234..9999
			employee.assigned = false
			employee.phone_number = FFaker::PhoneNumber.short_phone_number
			puts employee.first_name
		  end
		
		puts user.first_name
	  end
  end
		
  end

  
  desc "Create 25 employees with random names and addresses"
  task :pop_emp => :environment do
	require 'populator'
	require 'ffaker'
	password = "password"
	Apartment::Tenant.switch!('demoo')
	  User.populate 50 do |user|
	  	user.agency_id = 3
		user.first_name = FFaker::Name.first_name
		user.last_name = FFaker::Name.last_name
		user.email = FFaker::Internet.free_email
		user.city = FFaker::Address.city
		user.state = FFaker::AddressUS.state
		user.zipcode = FFaker::AddressUS.zip_code
		user.address = FFaker::AddressUS.street_address
		user.role = "Employee"
		user.encrypted_password = User.new(:password => password).encrypted_password
		user.sign_in_count = 0
		Employee.populate 1 do |employee|
			employee.user_id = user.id
			employee.first_name = user.first_name
			employee.last_name = user.last_name
			employee.email = user.email
			employee.ssn = 1234..9999
			employee.assigned = false
			employee.phone_number = FFaker::PhoneNumber.short_phone_number
			puts employee.first_name
		  end
		
		puts user.first_name
	  end
	  puts 'All done!!!'
  end
  
  desc "Create 25 employees with random names and addresses"
  task :pop_admin => :environment do
	require 'populator'
	require 'ffaker'

	password = "password"

	 Apartment::Tenant.switch!('orbie')
	  Admin.populate 15 do |admin|
		admin.first_name = FFaker::Name.first_name
		admin.last_name = FFaker::Name.last_name
		admin.email = FFaker::Internet.email
		admin.agency_id = 21
		admin.role = ["Account Manager", "Recruiter", "Payroll"]
		admin.encrypted_password = Admin.new(:password => password).encrypted_password
		admin.sign_in_count = 0
		admin.failed_attempts = 0
		puts admin.first_name
	  end
	  puts 'All done!!!'
  end
  

desc "Create 25 employees with random names and addresses"
  task :pop_emp => :environment do
	require 'populator'
	require 'ffaker'
	password = "password"
		Apartment::Tenant.switch!('demo')
	  User.populate 50 do |user|
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
		Employee.populate 1 do |employee|
			employee.user_id = user.id
			employee.first_name = user.first_name
			employee.last_name = user.last_name
			employee.email = user.email
			employee.ssn = 1234..9999
			employee.phone_number = FFaker::PhoneNumber.short_phone_number
			puts employee.first_name
		  end
	end
	  puts 'All done!!!'
 end