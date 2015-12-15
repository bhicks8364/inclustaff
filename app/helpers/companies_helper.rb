module CompaniesHelper
    def company_current_timesheets(company)
        @str = ""
        company.timesheets.current_week.each do |timesheet|
           @str += timesheet_user(timesheet)
        end
        @str.html_safe
    end
end
