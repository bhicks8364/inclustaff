# == Schema Information
#
# Table name: admins
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
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  company_id             :integer
#  role                   :string
#

class Admin < ActiveRecord::Base
  belongs_to :company
  has_many :orders, :through => :company
  has_many :shifts, :through => :company

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
         
         
  scope :account_managers, -> { where(role: "Account Manager")}
  scope :owners, -> { where(role: "Owner")}
  scope :payroll_admins, -> { where(role: "Payroll")}
  scope :hr, -> { where(role: "HR")}
  scope :recruiters, -> { where(role: "Recruiter")}
  scope :limited, -> { where(role: "Limited Access")}
         
  
  def account_manager?
    if self.role == "Account Manager"
      true
    else
      false
    end
  end
  def owner?
    if self.role == "Owner"
      true
    else
      false
    end
  end
  def payroll?
    if self.role == "Payroll"
      true
    else
      false
    end
  end
  def recruiter?
    if self.role == "Recruiter"
      true
    else
      false
    end
  end
  def hr?
    if self.role == "HR"
      true
    else
      false
    end
  end
  def limited?
    if self.role == "Limited Access"
      true
    else
      false
    end
  end
         
  def name
    "#{first_name} #{last_name}"
  end
  
    # def manager_timesheets
  #   if self.manager?
  #     self.orders.collect { |a| a.book } 
  #   end
  # end  
  def orders
    Order.by_manager(self.id)
  end
         
         
         
         
         
         
         
         
         
         
         
end
