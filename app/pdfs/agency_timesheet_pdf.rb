class AgencyTimesheetPdf < Prawn::Document
    attr_reader :agency, :timesheets, :view_context, :scoped_params, :signed_in
    def initialize(agency, timesheets, view_context, scoped_params, signed_in)
        @signed_in = signed_in
        @agency = agency
        @companies = @agency.companies
        @scope = scoped_params
        @timesheets = timesheets
        # @subtotal = price(@timesheets.map(&:gross_pay).sum)
        @view = view_context
        @color ||= @timesheets.approved.any? ? "cccccc" : "ff0000"
        # @status ||= @timesheets.approved.any? ? "Approved by: #{@timesheets.last.user_approved}" : ""
        super()
        text @agency.name, color: "cccccc", style: :bold, align: :center, size: 12
        move_down 20
        text @timesheets.last.time_frame if @scope != "all"
        stroke_horizontal_rule
        move_down 5
        text "Timesheet Report for #{@agency.name}", style: :bold, align: :left, size: 16
        timesheet_table
        move_down 20
        stroke_horizontal_rule
        move_down 5
        move_down 30
        text "Copy prepared by: #{@signed_in.name}", color: "cccccc", style: :bold, align: :right, size: 10
        start_new_page
        text @agency.name, color: "cccccc", style: :bold, align: :center, size: 12
        move_down 20
        text @timesheets.last.time_frame if @scope != "all"
        move_down 20
        stroke_horizontal_rule
        company_table
        
        

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
        if @scope == "all"
            @t = [["Company", "Week", "Employee", "Pay Rate", "Hours", "Gross Pay", "Approved by"]]
            @timesheets.map do |timesheet|
               @t <<  [timesheet.company.name, timesheet.week_ending, "#{timesheet.employee.name} #{timesheet.employee.id}", price(timesheet.pay_rate), timesheet.total_hours.round(2), price(timesheet.gross_pay), timesheet.user_approved.titleize]
            total += timesheet.gross_pay
            end
            @t << ["", "", "", "", "Total", price(total)]
            @t
        else
            total = 0
            @t = [["Company", "Employee", "Pay Rate", "Hours", "Gross Pay", "Approved by"]]
            @timesheets.map do |timesheet|
               @t <<  [timesheet.company.name, "#{timesheet.employee.name} #{timesheet.employee.id}", price(timesheet.pay_rate), timesheet.total_hours.round(2), price(timesheet.gross_pay), timesheet.user_approved.titleize]
               total += timesheet.gross_pay
            end
            @t << ["", "", "", "", "Total", price(total)]
            @t
        end
    end
    def company_table
        move_down 10
        
        borders = timesheet_rows.length - 2
        table(company_rows,  :row_colors => ["F0F0F0", "FFFFCC"], :position => :center, cell_style: { border_color: 'cccccc' }) do
            # row(0).font_style = :bold
            cells.padding = 8
            cells.borders = []
            row(0..borders).borders = [:bottom]
        end
        
    end
    def company_rows
        if @scope == "all"
        
        total = 0
        @t = [["Week", "Employee", "Pay Rate", "Hours", "Gross Pay", "Approved by"]]
            @companies.map do |company|
                @t <<  [company.name, "", "", "", "", ""]
               
            
            company.timesheets.map do |timesheet|
               @t <<  [timesheet.week_ending, "#{timesheet.employee.name} #{timesheet.employee.id}", price(timesheet.pay_rate), timesheet.total_hours.round(2), price(timesheet.gross_pay), timesheet.user_approved.titleize]
            total += timesheet.gross_pay
            end
            @t << ["", "", "", "", "Total", price(total)]
            @t
        end
        else
            total = 0
            @t = [["Week", "Employee", "Pay Rate", "Hours", "Gross Pay", "Approved by"]]
            @companies.map do |company|
                @t <<  [company.name, "", "", "", "", ""]
            
                company.timesheets.map do |timesheet|
                   @t <<  [timesheet.week_ending, "#{timesheet.employee.name} #{timesheet.employee.id}", price(timesheet.pay_rate), timesheet.total_hours.round(2), price(timesheet.gross_pay), timesheet.user_approved.titleize]
                total += timesheet.gross_pay
                end
                @t << ["", "", "", "", "Total", price(total)]
                
            end
            @t
        end
    end
    
    def price(number)
        @view.number_to_currency(number)
    end
end