# == Schema Information
#
# Table name: timesheets
#
#  id               :integer          not null, primary key
#  job_id           :integer
#  reg_hours        :decimal(, )
#  ot_hours         :decimal(, )
#  gross_pay        :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  state            :string
#  approved_by      :integer
#  shifts_count     :integer
#  total_bill       :decimal(, )
#  invoice_id       :integer
#  adjustments      :hstore
#  approved_by_type :string
#  total_hours      :decimal(, )
#  week             :date
#
# Indexes
#
#  index_timesheets_on_approved_by_type  (approved_by_type)
#  index_timesheets_on_deleted_at        (deleted_at)
#  index_timesheets_on_invoice_id        (invoice_id)
#  index_timesheets_on_job_id            (job_id)
#

module TimesheetsHelper
    def invoice_timesheet(timesheet)
        " #{ timesheet_sym(timesheet) } #{ number_to_currency(timesheet.total_bill)}".html_safe
    end
    
    def timesheet_popover(timesheet)
        if timesheet.approved?
            "<i class='fa fa-calendar button' data-placement='right' data-toggle='popover' title='#{ timesheet.job.name_title}'
            data-content='#{ timesheet.week_ending } - #{ number_to_currency(timesheet.total_bill) }'></i>".html_safe
        else
            "<i class='fa fa-calendar button' data-placement='right' data-toggle='popover' title='#{ timesheet.job.title} - #{ timesheet.employee.name}'
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
            "<i class='fa fa-clock-o green' data-placement='right' data-toggle='tooltip' title='#{ timesheet.state.titleize}'></i>".html_safe
        else
            "<i class='fa fa-clock-o red' data-placement='right' data-toggle='tooltip' title='#{ timesheet.state.titleize}'></i>".html_safe
        end
    end
    
    def hours_for(timesheet)
        "<span class='' data-toggle='tooltip' data-placement='top' title='Reg: #{timesheet.reg_hours.round(2)} OT: #{timesheet.ot_hours.round(2)} '>#{timesheet.total_hours.round(2)}</span>".html_safe
    end
    def pay_for(timesheet)
        if user_signed_in? && timesheet.total_hours <= 40
            "<span class='' data-toggle='tooltip' data-placement='top'
            title='#{number_to_currency(timesheet.job.pay_rate)} x  #{timesheet.reg_hours} '>#{number_to_currency(timesheet.gross_pay)}</span>".html_safe
        else
            "<span class='' data-toggle='tooltip' data-placement='top'
            title='Pay: #{number_to_currency(timesheet.gross_pay)}
            Bill: #{number_to_currency(timesheet.total_bill)} '>#{number_to_currency(timesheet.gross_pay)}</span>".html_safe
        end
    end
end
