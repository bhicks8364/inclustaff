# == Schema Information
#
# Table name: jobs
#
#  id           :integer          not null, primary key
#  employee_id  :integer
#  order_id     :integer
#  title        :string
#  description  :string
#  start_date   :date
#  pay_rate     :decimal(, )
#  end_date     :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  active       :boolean
#  deleted_at   :datetime
#  recruiter_id :integer
#

FactoryGirl.define do
 	factory :job do
  	title      {FFaker::Job.title}
  	description {FFaker::LoremFR.paragraph}
  	start_date  Date.today
	  pay_rate    12.55
	  end_date    nil
	  active  true 
	  order_id 1
    
  end

end
