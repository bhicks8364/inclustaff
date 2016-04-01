class TimesheetPdf < Prawn::Document
    attr_reader :timesheet, :view_context, :current_agency
    def initialize(timesheet, view_context, current_agency)
        super() 
        @timesheet = timesheet
        @subtotal = @timesheet.gross_pay
        @employee = @timesheet.employee
        @current_agency = current_agency
        @company = @timesheet.company
        @job_order = @timesheet.job.order
        @view = view_context
        @color ||= @timesheet.approved? ? "cccccc" : "ff0000"
        @status ||= @timesheet.approved? ? "Approved by: #{@timesheet.user_approved}" : ""
        move_down 10
        text "Invoice Id #:#{@timesheet.id }", :align => :right
        font "Times-Roman"
        text "Dates: #{@timesheet.time_frame }", :color => @color, align: :left, size: 14
        text @status, :color => "#ccc", align: :right, size: 16
        move_down 20
        text " #{@company.name } - #{@job_order.title }", size: 30, style: :bold, :align => :center
        stroke_horizontal_rule
        move_down 5
        text " #{@current_agency.name }", align: :left, size: 14
        text "Employee: #{@employee.name }", align: :right, size: 14
        move_down 20
        text "Gross Pay: #{@view.number_to_currency(@subtotal)}", style: :bold, align: :right, size: 16
        move_down 20
        text "#{helpers.pluralize(@timesheet.shifts.count, 'shift')}", align: :right, size: 14
        move_down 2
        stroke_horizontal_rule
        
        
        move_down 30
        stroke_horizontal_rule
        
       
        move_down 20
        # start_new_page
        # notes
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
        @t = [["ID", "Date", "Pay Rate", "Hours", "Time In", "Time Out"]]
        @timesheet.shifts.order(:time_in).map do |shift|
           @t <<  [shift.id, shift.work_date, price(shift.pay_rate), shift.hours_worked.round(2), shift.time_in.stamp("11:30am"), shift.time_out.stamp("11:30am")]
        end
        @t
    end
    
    def price(number)
        @view.number_to_currency(number)
    end
    def words
        string = @timesheet.job.order.notes
        text string
        y_position = cursor - 20
        [:truncate, :expand, :shrink_to_fit].each_with_index do |mode, i|
         text_box string, :at => [i * 150, y_position],
         :width => 100,
         :height => 50,
         :overflow => mode
        end
    end
    
    def notes
        string = @job_order.notes
        text_box string, :at => [0, cursor],
         :width => 400,
         :height => 500,
         :overflow => :shrink_to_fit
    end
    
    
    
    
   
    def helpers
        ActionController::Base.helpers
    end
end