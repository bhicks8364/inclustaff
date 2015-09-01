# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :string
#  first_name             :string
#  last_name              :string
#  deleted_at             :datetime
#  can_edit               :boolean
#  code                   :string
#  address                :string
#  city                   :string
#  state                  :string
#  zipcode                :string
#  employee_id            :integer
#

class User < ActiveRecord::Base
  has_one :employee
  has_many :shifts, through: :employee
  has_one :current_job, through: :employee
  # belongs_to :company

  accepts_nested_attributes_for :employee
  
  # validates :company_id,  presence: true
  validates :role,  presence: true

  
  after_save :set_employee, :set_emp_id
  

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
        
  # devise :database_authenticatable, :validatable, password_length: 4..6      
  delegate :ssn, to: :employee
  
  # def active_for_authentication?
  #   # Uncomment the below debug statement to view the properties of the returned self model values.
  #   # logger.debug self.to_yaml

  #   super && employee.assigned?
  # end
  
  def set_emp_id
    self.employee_id = self.employee.id
  end

  
  def name
    "#{first_name} #{last_name}"
  end

  def employee?
    role == "Employee"
  end
  
  def code
   self.first_name[0,1] + self.last_name[0,1] + self.ssn.to_s
  end

  
  
  def set_employee
    if role == "Employee"
      Employee.find_or_create_by(email: self.email) do |employee|
        employee.user_id = self.id
        employee.first_name = self.first_name
        employee.last_name = self.last_name
        employee.ssn = 1234
      end

    end
  end
  
  











        
end
