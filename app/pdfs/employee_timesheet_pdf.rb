class EmployeeTimesheetPdf < Prawn::Document
    attr_reader :employee, :pdf_timesheets, :view_context, :scoped_params, :signed_in, :current_agency
    def initialize(employee, pdf_timesheets, view_context, scoped_params, signed_in, current_agency)
        @employee = employee
        @signed_in = signed_in
        @scope = scoped_params
        @current_agency = current_agency
        @pdf_timesheets = pdf_timesheets
        @view = view_context
        @color ||= @pdf_timesheets.last.approved? ? "cccccc" : "ff0000" if @pdf_timesheets.any?
        @status ||= @pdf_timesheets.last.approved? ? "Approved by: #{@pdf_timesheets.last.user_approved}" : "" if @pdf_timesheets.any?
        super()
        text @agency.name, color: "cccccc", style: :bold, align: :center, size: 12
        move_down 20
        move_down 20
        text @pdf_timesheets.last.time_frame if @scope != "all" if @pdf_timesheets.any?
        stroke_horizontal_rule
        move_down 5
        text "Employee Timesheet Report for #{@employee.name}", style: :bold, align: :left, size: 16
        timesheet_table
        move_down 20
        stroke_horizontal_rule
        move_down 5
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
        total = 0
        if @scope == "all"
            @t = [["EmpID", "Week", "Pay Rate", "Hours", "Gross Pay", "Approved by"]]
            @pdf_timesheets.map do |timesheet|
               @t <<  [timesheet.id, timesheet.week_ending, price(timesheet.pay_rate), timesheet.total_hours.round(2), price(timesheet.gross_pay), timesheet.user_approved.titleize]
            total += timesheet.gross_pay
            end
            @t << ["", "", "", "", "Total", price(total)]
            @t
        else
            @t = [["EmpID", "Employee", "Pay Rate", "Hours", "Gross Pay", "Approved by"]]
            @pdf_timesheets.map do |timesheet|
               @t <<  [timesheet.employee.id, timesheet.employee.name, price(timesheet.pay_rate), timesheet.total_hours.round(2), price(timesheet.gross_pay), timesheet.user_approved.titleize]
                total += timesheet.gross_pay
            end
            @t << ["", "", "", "", "Total", price(total)]
            @t
            
        end
    end
    
    def price(number)
        @view.number_to_currency(number)
    end
end