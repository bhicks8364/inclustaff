class TimesheetPdf < Prawn::Document
    attr_reader :timesheet, :view_context
    def initialize(timesheet, view_context)
        super() 
        @timesheet = timesheet
        @subtotal = @timesheet.gross_pay
        @employee = @timesheet.employee
        @current_agency = @timesheet.agency
        @company = @timesheet.company
        @view = view_context
        @color ||= @timesheet.approved? ? "cccccc" : "ff0000"
        @status ||= @timesheet.approved? ? "Approved by: #{@timesheet.user_approved}" : ""
        move_down 10
        text "Invoice Id #:#{@timesheet.id }", :align => :right
        font "Times-Roman"
        text "Dates: #{@timesheet.time_frame }", :color => @color, align: :left, size: 14
        text @status, :color => "#ccc", align: :right, size: 16
        move_down 20
        text " #{@company.name }", size: 30, style: :bold, :align => :center, :size => 18
        move_down 10
        text "Employee: #{@employee.name }"
        move_down 20
        text "Gross Pay: #{@view.number_to_currency(@subtotal)}", style: :bold, align: :right, size: 16
        move_down 20
        text "#{helpers.pluralize(@timesheet.shifts.count, 'shift')}", align: :right, size: 14
        move_down 2
        stroke_horizontal_rule
        timesheets
        
        move_down 30
        stroke_horizontal_rule
        
       
        move_down 20
    end
    def details
        stroke_horizontal_rule
        text_box "Another text box with no :width option passed, so it will " +
         "flow to a new line whenever it reaches the right margin. ",
         :at => [200, 100]


    end
    
    def timesheets
        move_down 10
        
        borders = timesheets2.length - 2
        table(timesheets2,  :row_colors => ["F0F0F0", "FFFFCC"], :position => :center, cell_style: { border_color: 'cccccc' }) do
            row(0).font_style = :bold
            cells.padding = 12
            cells.borders = []
            row(0..borders).borders = [:bottom]
        end
        
    end
    
    
    def timesheets2
        @t = [["ID", "Date", "Pay Rate", "Hours", "Shift Earnings"]]
        @timesheet.shifts.map do |shift|
           @t <<  [shift.id, shift.work_date, price(shift.pay_rate), shift.hours_worked.round(2), price(shift.earnings)]
        end
        @t
    end
    
    def price(number)
        @view.number_to_currency(number)
    end
    def words
        string = "This is the sample text used for the text boxes. See how it " +
         "behave with the various overflow options used."
        text string
        y_position = cursor - 20
        [:truncate, :expand, :shrink_to_fit].each_with_index do |mode, i|
         text_box string, :at => [i * 150, y_position],
         :width => 100,
         :height => 50,
         :overflow => mode
        end
    end

   
    def helpers
        ActionController::Base.helpers
    end
end