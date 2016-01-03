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
        elsif company.orders.active.blank?
          @str +=  "No Active Job Orders"
        elsif company.orders.needs_attention.any? 
            company.orders.needs_attention.each do |order|
               @str += status_tag(order, class: 'status_msg')
            end
          
        else company.orders.any? 
            company.orders.each do |order|
               @str += status_tag(order, class: 'status_msg')
            end
        end
        @str.html_safe
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
