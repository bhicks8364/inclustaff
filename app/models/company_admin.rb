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
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#
# Indexes
#
#  index_company_admins_on_confirmation_token    (confirmation_token) UNIQUE
#  index_company_admins_on_email                 (email) UNIQUE
#  index_company_admins_on_invitation_token      (invitation_token) UNIQUE
#  index_company_admins_on_invitations_count     (invitations_count)
#  index_company_admins_on_invited_by_id         (invited_by_id)
#  index_company_admins_on_reset_password_token  (reset_password_token) UNIQUE
#  index_company_admins_on_unlock_token          (unlock_token) UNIQUE
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
  devise :invitable, :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable
         
  geocoded_by :current_sign_in_ip
  after_validation :geocode
  
  
  validates :company_id, presence: true
  before_validation :set_name
  
  scope :owners, -> { where(role: "Owner")}
  scope :managers, -> { where(role: "Manager")}
  scope :hr, -> { where(role: "HR")}
  scope :limited, -> { where(role: "Limited Access")}
  scope :timeclocks, -> { where(role: "Timeclock")}
  scope :real_users, -> { where.not(role: "Timeclock")}
  scope :current_week, -> {
          start = Time.current.beginning_of_week
          ending = start.end_of_week
          where(updated_at: start..ending)}
  def set_name;   self.name = "#{first_name} #{last_name}"; end
  def to_s; name; end
  def owner?;           role == "Owner";  end
  def payroll?;           role == "HR";  end
  def manager?; role == "Manager"; end
  def recruiter?;           false;  end
  def account_manager?;           false;  end
  def agency?;           false;  end
  def hr?;           role == "HR";  end
  def timeclock?;           role == "Timeclock";  end
  def company_admin?;           true;  end
  def admin?;           false;  end
  def employee?;           false;  end
  def online?
    if current_sign_in_at.present?
      current_sign_in_at > 10.minutes.ago
    end
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
