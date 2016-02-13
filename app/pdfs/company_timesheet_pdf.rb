class CompanyTimesheetPdf < Prawn::Document
    attr_reader :company, :timesheets, :view_context, :signed_in
    def initialize(company, timesheets, view_context, signed_in)
        @company = company
        @signed_in = signed_in
        @agency = @company.agency
        @timesheets = timesheets
        @subtotal = timesheets.sum(:gross_pay)
        @view = view_context
        @color ||= @timesheets.last.approved? ? "cccccc" : "ff0000"
        @status ||= @timesheets.last.approved? ? "Approved by: #{@timesheets.last.user_approved}" : ""
        super()
        text @agency.name, color: "cccccc", style: :bold, align: :center, size: 12
        move_down 20
        stroke_horizontal_rule
        move_down 5
        text @company.name, style: :bold, align: :left, size: 16
        timesheet_table
        move_down 20
        stroke_horizontal_rule
        move_down 5
        text "Total: #{price(@subtotal)}", style: :bold, align: :right, size: 14
        move_down 30
        text "Copy prepared by: #{@signed_in.name}", color: "cccccc", style: :bold, align: :right, size: 10
        
    end
    def timesheet_table
        move_down 10
        
        borders = timesheet_rows.length - 2
        table(timesheet_rows,  :row_colors => ["F0F0F0", "FFFFCC"], :position => :center, cell_style: { border_color: 'cccccc' }) do
            # row(0).font_style = :bold
            cells.padding = 8
            cells.borders = []
            row(0..borders).borders = [:bottom]
        end
        
    end
    def timesheet_rows
        @t = [["EmpID", "Week", "Employee", "Pay Rate", "Hours", "Gross Pay", "Approved by"]]
        @timesheets.map do |timesheet|
           @t <<  [timesheet.employee.id, timesheet.week_ending, timesheet.employee.name, price(timesheet.pay_rate), timesheet.total_hours.round(2), price(timesheet.gross_pay), timesheet.user_approved.titleize]
        end
        @t
    end
    
    def price(number)
        @view.number_to_currency(number)
    end
end