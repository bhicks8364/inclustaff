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

module CompaniesHelper
    def company_current_timesheets(company)
        @str = ""
        company.timesheets.current_week.each do |timesheet|
           @str += timesheet_user(timesheet)
        end
        @str.html_safe
    end
    def company_status(company)
        @str = " "
        if company.orders.blank?
            @str +=  "No Job Orders"
        elsif company.orders.active.none?
            @str +=  "No Active Job Orders"
        elsif company.orders.needs_attention.any? 
            @str += "#{pluralize(company.orders.needs_attention.count, 'open job order')}"
        else company.orders.any? 
            @str += "#{pluralize(company.orders.count, 'job order')}"
        end
        @str
    end
    
   def company_orders_msgs(company)
       @str = ""
       if company.orders.blank?
          @str +=  "No Job Orders"
        elsif company.orders.active.blank?
          @str +=  "No Active Job Orders"
        elsif company.orders.needs_attention.any? 
          @str +=  "Overdue" + "  #{company.orders.overdue.count}<br>"
          @str +=  "Priority" + "    #{company.orders.priority.count} <br>"
          @str +=  "Open" + "  #{company.orders.needs_attention.count} <br>"
          @str +=  "Filled " + "  #{company.orders.filled.count}<br>"
        elsif !company.orders.needs_attention.any?
            @str += "All orders are filled."
        end
        @str.html_safe
    end
end
