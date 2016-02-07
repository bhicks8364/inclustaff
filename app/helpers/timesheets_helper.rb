module TimesheetsHelper
    def invoice_timesheet(timesheet)
        "<small> W/E: #{ timesheet.week_ending }</small> #{ number_to_currency(timesheet.total_bill)}".html_safe
    end
    
    def timesheet_popover(timesheet)
        if timesheet.approved?
            "<i class='fa fa-user' data-placement='right' data-toggle='popover' title='#{ timesheet.job.name_title}'
            data-content='#{ timesheet.week_ending } - #{ number_to_currency(timesheet.total_bill) }'></i>".html_safe
        else
            "<i class='fa fa-user' data-placement='right' data-toggle='popover' title='#{ timesheet.job.title} - #{ timesheet.employee.name}'
            data-content='#{ timesheet.week_ending } - #{ number_to_currency(timesheet.total_bill) }'></i>".html_safe
        end
    end
    def timesheet_user(timesheet)
        if timesheet.approved?
            "<span class='green'>#{timesheet_popover(timesheet)}</span>".html_safe
        else
            "<span class='red'>#{timesheet_popover(timesheet)}</span>".html_safe
        end
    end
    def timesheet_sym(timesheet)
        if timesheet.approved?
            "<i class='fa fa-user green' data-placement='right' data-toggle='tooltip' title='#{ timesheet.job.name_title}'></i>".html_safe
        else
            "<i class='fa fa-user green' data-placement='right' data-toggle='tooltip' title='#{ timesheet.job.name_title}'></i>".html_safe
        end
    end
end
