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
#  agency_id              :integer
#  resume_id              :integer
#  checked_in_at          :datetime
#  name                   :string
#  latitude               :float
#  longitude              :float
#  start_date             :date
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
#  index_users_on_agency_id             (agency_id)
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_resume_id             (resume_id)
#  index_users_on_role                  (role)
#

class User < ActiveRecord::Base
  acts_as_messageable

  has_one :employee, dependent: :destroy
  has_many :jobs, through: :employee
  has_many :shifts, through: :employee
  has_many :work_histories, through: :employee
  has_many :skills, through: :employee
  has_one :current_job, through: :employee
  has_many :events
  attachment :resume, extension: ["pdf", "doc", "docx"]
  belongs_to :agency

  accepts_nested_attributes_for :employee
  # accepts_nested_attributes_for :work_histories, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true

  validates :agency_id,  presence: true
  validates :role,  presence: true
  validates :code, uniqueness: true

  # GEOCODER
  geocoded_by :fulladdress
  after_validation :geocode
  def fulladdress
    "#{address} #{city}, #{state}"
  end
  # devise :invitable, :database_authenticatable, :authentication_keys => [:code]
  devise :invitable, :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

  scope :unassigned, -> { joins(:employee).merge(Employee.unassigned)}
  scope :available, -> { joins(:employee).merge(Employee.available)}
  scope :ordered_by_last_name, -> { order(last_name: :asc) }
  scope :ordered_by_check_in, -> { order(checked_in_at: :asc) }
  def timeclock?;           false;  end
  before_validation do
    self.role = "Employee"
    self.name = "#{first_name} #{last_name}"
  end
  before_validation :set_code, :set_role
  after_create :set_employee, if: :has_no_employee?
  
  def mention_data; {name: "#{name}", content: "#{title_company}"}; end
  def has_no_employee?
    employee.nil?
  end
  def owner?
    false
  end

  def set_role
    # Maybe this should change depending on if they have ever worked for the agency or if theyre just a candidate
      self.role = "Employee"
  end

  def to_param
    "#{id}-#{name.parameterize }"
  end
  def online?
    if current_sign_in_at.present?
      current_sign_in_at > 10.minutes.ago
    end
  end

  scope :dns, -> { joins(:employee).merge(Employee.dns)}
  scope :unassigned, -> { joins(:employee).merge(Employee.unassigned)}
  scope :available, -> { joins(:employee).merge(Employee.available)}
  scope :assigned, -> { joins(:employee).merge(Employee.with_active_jobs)}
  scope :online, -> { where("updated_at > ?", 10.minutes.ago) }

  def company_admin?;           false;  end
  def admin?;           false;  end
  def employee?;           true;  end

  def set_check_in!
    if checked_in_at.nil?
      self.update(checked_in_at: created_at)
    end
  end
  def company
    employee.company if assigned?
  end
  def title_company
    if assigned?
      "#{company.try(:name)} #{try(:title)} "
    else
      "Unassigned!!!!"
    end
  end
  def employee?
    role == "Employee"
  end
  def assigned?
    employee.assigned?
  end

  def reset_code!
    new_code = last_name.upcase[0,4] + rand(1000..9999).to_s
    self.update(code: new_code)
  end
  def set_code
    if code.nil?
      new_code = last_name.upcase[0,4] + rand(1000..9999).to_s
      self.code = new_code
    else
    end
  end
  def reset_password!
    self.update(password: code, password_confirmation: code)
  end
  def set_emp_id
    self.employee_id = employee.id
  end



  def set_employee
    self.employee = Employee.find_or_create_by(email: self.email) do |employee|
      employee.user_id = self.id
      employee.first_name = self.first_name
      employee.last_name = self.last_name
      employee.ssn = 1234
     end
  end
   # IMPORT TO CSV
  def self.assign_from_row(row, agency_id)

    user = User.where(email: row[:email]).first_or_initialize
    user.assign_attributes row.to_hash.slice(:first_name, :last_name, :agency_id, :email, :code, :role, :address, :city, :state, :zipcode)
    user.password = "password"
    user.password_confirmation = "password"
    user.agency_id = agency_id
    user
  end

   # EXPORT TO CSV
  def self.to_csv
    attributes = %w{id last_name first_name email code role fulladdress address city state zipcode}
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << user.attributes.values_at(*attributes)
      end
    end
  end

  def applied_to(order_id)
    Event.where(user_id: self.id, eventable_id: order_id, action: 'applied').any?
  end
  def is_following?(user)
    Event.where(admin_id: self.id, eventable: user, action: 'followed').any?
  end

  def mailboxer_email(object)
    nil
  end
end
