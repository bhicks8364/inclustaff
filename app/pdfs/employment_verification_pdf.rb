class EmploymentVerificationPdf < Prawn::Document
    attr_reader :employee, :view_context, :signed_in, :current_agency
    def initialize(employee, view_context, signed_in, current_agency)
        @employee = employee
        @job = @employee.current_job
        @signed_in = signed_in
        @current_state = @employee.jobs.includes(:shifts).order('shifts.week').last.state
        @current_agency = current_agency
        if @current_state == "Currently Working"
            @color = "green"
        else
            @color = "#ccc"
        end
        # @pdf_timesheets = pdf_timesheets
        @view = view_context
        # @color ||= @pdf_timesheets.last.approved? ? "cccccc" : "ff0000" if @pdf_timesheets.any?
        # @status ||= @pdf_timesheets.last.approved? ? "Approved by: #{@pdf_timesheets.last.user_approved}" : "" if @pdf_timesheets.any?
        super()
        
        text "Employee Verification for #{@employee.name}", style: :bold, align: :left, size: 12
        stroke_horizontal_rule
        move_down 5
        text @current_agency.name, style: :bold, align: :center, size: 12
        move_down 5
        stroke_horizontal_rule
        move_down 5
        text @current_state, color: @color, align: :right, size: 12
        move_down 20
        
        stroke_horizontal_rule
        move_down 5
        @employee.jobs.includes(:shifts).order('shifts.week').each do |j|
            move_down 15
            text "Company: #{j.company.name}", style: :bold, align: :left, size: 12
            move_down 2
            text " #{j.state}", color: @color, style: :bold, align: :left, size: 12
            move_down 2
            text "#{j.title}: #{j.shifts.order(:time_in).first.work_date} - #{j.shifts.order(:time_in).last.work_date}"
            move_down 3
            text "Pay Rate: #{@view.number_to_currency(j.pay_rate)}"
            move_down 2
            stroke_horizontal_rule
        end
        move_down 25
        stroke_horizontal_rule
        move_down 20
        text "Timesheets", style: :bold, align: :left, size: 16
        move_down 15
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
        total_pay = 0
        total_reg = 0
        total_ot = 0
        total_hours = 0
            @t = [["Dates", "Reg Hours", "OT Hours", "Total Hours", "Gross Pay", "FEIN" ]]
            @employee.timesheets.order(week: :desc).map do |timesheet|
              @t <<  [timesheet.week, timesheet.reg_hours.round(2), timesheet.ot_hours.round(2), timesheet.total_hours.round(2), price(timesheet.gross_pay), "#{timesheet.job_id}"]
                total_pay += timesheet.gross_pay
                total_reg += timesheet.reg_hours
                total_ot += timesheet.ot_hours
                total_hours += timesheet.total_hours
            end
            @t << ["", "#{total_reg.round(2)}", "#{total_ot.round(2)}", "#{total_hours.round(2)}", "#{price(total_pay)}", ""]
            @t
    end
    
    def price(number)
        @view.number_to_currency(number)
    end
end