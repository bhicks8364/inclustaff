# == Schema Information
#
# Table name: work_histories
#
#  id            :integer          not null, primary key
#  employee_id   :integer          not null
#  employer_name :string
#  title         :string
#  start_date    :date
#  end_date      :date
#  description   :text
#  current       :boolean          default(FALSE)
#  may_contact   :boolean          default(FALSE)
#  supervisor    :string
#  phone_number  :string
#  pay           :string
#  pay_period    :string
#

module WorkHistoriesHelper
    
end
