# == Schema Information
#
# Table name: company_admins
#
#  id                     :integer          not null, primary key
#  first_name             :string
#  last_name              :string
#  phone_number           :string
#  company_id             :integer
#  role                   :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  latitude               :float
#  longitude              :float
#

class CompanyAdmin < ActiveRecord::Base
  belongs_to :company

  has_many :jobs, through: :company
  has_many :timesheets, through: :jobs
  has_many :shifts, through: :timesheets
  has_many :events
  has_many :eventables, :through => :events
  has_many :job_comments, through: :jobs, source: "comments"
  has_many :timesheet_comments, through: :timesheets, source: 'comments'
  has_many :shift_comments, through: :shifts, source: 'comments'
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable
         
  geocoded_by :current_sign_in_ip
  after_validation :geocode
  
  
  validates :company_id, presence: true
  before_validation :set_name
 
  def set_name;   self.name = "#{first_name} #{last_name}"; end
  def to_s; name; end
  def owner?;           role == "Owner";  end
  def recruiter?;           false;  end
  def account_manager?;           false;  end
  def hr?;           role == "HR";  end
  def timeclock?;           role == "Timeclock";  end
  # TODO -> dont think admin? should return true for company_admin... Clashing with policies - shared controllers
  def admin?;           true;  end
  def online?
    updated_at > 10.minutes.ago
  end
  def mention_data; {name: "#{name}", content: "#{role}", company: "#{company.name}"}; end
  def managed_orders
    if owner?
      company.orders
    else
      Order.by_manager(id)
    end
  end
  
  
 
end
