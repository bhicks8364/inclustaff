# == Schema Information
#
# Table name: employees
#
#  id           :integer          not null, primary key
#  first_name   :string
#  last_name    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  email        :string
#  ssn          :string
#  phone_number :string
#  user_id      :integer
#  deleted_at   :datetime
#

FactoryGirl.define do
 	factory :employee do
  	    first_name      {FFaker::Name.first_name}
  	    last_name {FFaker::Name.last_name}
  	    email  {FFaker::Internet.email}
	    ssn    {5555}
	    phone_number    {FFaker::PhoneNumber.short_phone_number}
    
  end

end
