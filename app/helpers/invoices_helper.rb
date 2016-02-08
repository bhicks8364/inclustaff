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
    def inv_timesheets_collaspe(inv)
      "<a class='black text-center' role='button' data-toggle='collapse' href='#collapseInv_#{inv.id}' aria-expanded='false' aria-controls='collapseInv_#{inv.id}'>
       #{inv_sym(inv)}  <small>#{inv.company.name}</small><span class='pull-right'><strong>#{inv.week}</strong></span>
      </a>".html_safe
    end
    def inv_sym(inv)
        if inv.paid?
            "<span class='green'><i class='fa fa-check' data-toggle='tooltip' data-placement='top' 
            title='#{inv.state} on #{inv.paid_on}'></i></span>".html_safe
        elsif inv.unpaid? && inv.timesheets_approved?
            "<span class='red'><i class='fa fa-exclamation' data-toggle='tooltip' data-placement='top'
            title='#{inv.state} - Due #{distance_of_time_in_words(inv.due_by, Time.current, include_seconds: true)} ago'></i></span>".html_safe
        elsif !inv.timesheets_approved? && inv.current?
            "<span class='black'><i class='fa fa-history' data-toggle='tooltip' data-placement='top'
            title='#{inv.state} - #{pluralize(inv.timesheets.count, 'timesheet')}'></i></span>".html_safe
        elsif !inv.timesheets_approved?
            "<span class='red'><i class='fa fa-clock-o' data-toggle='tooltip' data-placement='top'
            title='#{inv.state} - #{pluralize(inv.timesheets.pending.count, 'unapproved timesheet')}'></i></span>".html_safe
        end
    end
    
end
