module InvoicesHelper
    def invoice_calendar(options={}, &block)
      raise 'Invoice calendar requires a block' unless block_given?
      Calendar.new(self, options).render(&block)
    end
    def invoice_popover(invoice)
        if invoice.paid?
            "<span>Week Ending: #{invoice.week_ending}<small>Invoice ID: #{invoice.id}</small> <i class='fa fa-check-circle' data-placement='top' data-toggle='popover' title='#{ distance_of_time_in_words(Time.current, invoice.due_by) }' 
            data-content='#{ number_to_currency(invoice.balance) }'></i> </span>".html_safe
        else
            "<span><small>ID: #{invoice.id}</small>  <i class='fa fa-times-circle' data-placement='top' data-toggle='popover' title='#{ distance_of_time_in_words(Time.current, invoice.due_by) }' 
            data-content='#{ number_to_currency(invoice.balance) }'></i> </span>".html_safe
        end
    end
    def timesheets_for(invoice)
        @str = ""
        invoice.timesheets.each do |timesheet|
           @str += timesheet_user(timesheet)
        end
        @str.html_safe
    end
end
