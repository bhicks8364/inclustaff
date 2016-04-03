# == Schema Information
#
# Table name: companies
#
#  id            :integer          not null, primary key
#  name          :string
#  address       :string
#  state         :string
#  zipcode       :string
#  contact_name  :string
#  contact_email :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  city          :string
#  balance       :decimal(, )
#  phone_number  :string
#  user_id       :integer
#  agency_id     :integer
#  admin_id      :integer
#  preferences   :hstore           default({})
#
# Indexes
#
#  index_companies_on_admin_id   (admin_id)
#  index_companies_on_agency_id  (agency_id)
#  index_companies_on_user_id    (user_id)
#

class Company < ActiveRecord::Base
    include ArelHelpers::ArelTable
    include ArelHelpers::JoinAssociation
    belongs_to :agency
    belongs_to :account_manager, class_name: "Admin", foreign_key: "admin_id"
    has_many :admins, class_name: "CompanyAdmin", foreign_key: "company_id", dependent: :destroy
    has_many :events, through: :admins
    has_many :payroll_admins, -> { where role: "Payroll" }, through: :agency, class_name: "Admin"
    has_many :invoices
    has_many :orders, dependent: :destroy
    has_many :skills, through: :orders
    has_many :jobs, through: :orders
    has_many :active_jobs, -> { where active: true }, through: :orders, class_name: "Job"
    has_many :employees, through: :jobs
    has_many :users, through: :employees
    has_many :shifts, through: :jobs
    has_many :timesheets, through: :jobs
    has_many :current_timesheets, through: :jobs
    has_many :account_managers, through: :orders
    has_many :recruiters, through: :jobs
    has_many :timesheet_events, through: :timesheets, source: 'events'
    has_many :job_events, through: :jobs, source: 'events'
    has_many :admin_events, through: :admins, source: 'events'
    has_many :order_events, through: :orders, source: 'events'
    has_many :job_comments, through: :jobs, source: 'comments'
    has_many :timesheet_comments, through: :timesheets, source: 'comments'
    has_many :shift_comments, through: :shifts, source: 'comments'

    scope :with_pending_jobs, -> { joins(:orders => :jobs).merge(Job.pending_approval)}
    scope :with_active_jobs, -> { joins(:orders => :jobs).merge(Job.currently_working)}
    scope :with_open_orders, -> { joins(:orders).merge(Order.needs_attention)}
    scope :with_overdue_orders, -> { joins(:orders).merge(Order.overdue)}
    scope :with_balance, -> { where(Company[:balance].gt(0).and(Company[:balance].not_eq(nil))) }
    scope :with_current_timesheets, -> { joins(:timesheets).merge(Timesheet.current_week.distinct)}
    scope :ordered_by_current_bill, -> { includes(:current_timesheets).order('timesheets.total_bill') }
    scope :with_late_timesheets, -> { joins(:timesheets).merge(Timesheet.needing_approval)}
    scope :newly_added, -> { where(Company[:created_at].gteq(Date.today.beginning_of_week)) }

    def comments
      timesheet_comments + job_comments + shift_comments
    end
    
    # send_notification_email isn't hooked up. Maybe just internal mail. Conversation or Event or idk?
    # after_create :send_notification_email, :create_company_admin

    validates :name,  presence: true, length: { maximum: 50 }
    # validates :agency_id,  presence: true
    
    # validates :contact_name,  presence: true, length: { maximum: 20 }
    # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    # validates :contact_email, presence: true, length: { maximum: 255 },
                    # format: { with: VALID_EMAIL_REGEX },
                    # uniqueness: { case_sensitive: false }


    def create_company_admin
      first_name, last_name = contact_name.split()
      admins.invite!(
        company_id: id,
        first_name: first_name,
        last_name: last_name,
        role: "Owner"
      )
    end

    def contact
      CompanyAdmin.where(email: contact_email).first
    end
     def send_notification_email
       NotificationMailer.new_company(self).deliver_later
     end

    def to_s; name; end
    def owner
      admins.where(role: "Owner").first || admins.first
    end
    def current_agency
      if orders.any?
          orders.last.agency
      end
    end
    def to_param
      "#{id}-#{name.parameterize}"
    end
    def fulladdress
      "#{address} #{city}, #{state}"
    end
    def self.by_account_manager(admin_id)
        joins(:orders).where(orders: { account_manager_id: admin_id })
    end
    def self.by_recruiter(admin_id)
        joins(:orders => :jobs).where(jobs: { recruiter_id: admin_id })
    end

    def current_payroll_cost
       timesheets.current_week.distinct.sum(:gross_pay)
    end
    def current_billing
       timesheets.current_week.distinct.sum(:total_bill)
    end
    def last_week_billing
        timesheets.last_week.distinct.sum(:total_bill)
    end

    def set_payroll_cost!
        cost = timesheets.current_week.distinct.sum(:total_bill)
        update(balance: cost)
    end

    # IMPORT TO CSV
    def self.assign_from_row(row, agency_id)
        company = Company.where(name: row[:name]).first_or_initialize
        company.assign_attributes row.to_hash.slice(:name, :address, :city, :state, :zipcode, :contact_name, :contact_email, :admin_id, :phone_number)
        company.agency_id = agency_id
        company
    end

    # EXPORT TO CSV
    def self.to_csv
      attributes = %w{id name address city state contact_name contact_email balance phone_number admin_id agency_id}
      CSV.generate(headers: true) do |csv|
        csv << attributes

        all.each do |company|
          csv << attributes.map{ |attr| company.send(attr) }
        end
      end
    end

end
