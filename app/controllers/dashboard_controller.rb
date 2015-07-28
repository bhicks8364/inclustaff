class DashboardController < ApplicationController
    
    def home
    end
    def company_view
        @company = Company.find(2)
        @current_timesheets = @company.timesheets.this_week.distinct
        @last_week = @company.timesheets.last_week.distinct
        @timesheets = @company.timesheets.distinct
    end
    def employee_view
        
    end
    
    
    
end