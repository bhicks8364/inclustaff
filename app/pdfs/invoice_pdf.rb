class InvoicePdf < Prawn::Document
    attr_reader :invoice, :current_agency, :company, :subtotal, :timesheet_data, :view_context
    def initialize(invoice, current_agency, company, subtotal, timesheet_data, view_context)
        super() 
        @invoice = invoice
        @subtotal = subtotal
        @timesheet_data = timesheet_data
        @current_agency = current_agency
        @company = company
        @view = view_context
        @color ||= @invoice.paid? ? "cccccc" : "ff0000"
        font "Times-Roman"
        text "Due Date: #{@invoice.due_by.stamp('11/12/2016') }", :color => @color, align: :right
        
        
        move_down 20
        text "For staffing services provided by: #{@current_agency.name }", size: 30, style: :bold, :align => :center, :size => 18
        move_down 10
        text "Invoice Id #:#{@invoice.id }", :align => :right
        move_down 10
        text "Invoice for #{@company.name }", :align => :left
        move_down 20
        text "Subtotal: #{@view.number_to_currency(@subtotal)}", style: :bold, align: :right, size: 16
        move_down 20
        text "#{helpers.pluralize(@invoice.timesheets.count, 'timesheet')}", align: :right, size: 14
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
        @t = [["ID", "Type", "Employee", "Bill Rate", "Hours", "Total Bill"]]
        @invoice.timesheets.map do |timesheet|
           @t <<  [timesheet.id, timesheet.order.industry, timesheet.employee.name, price(timesheet.bill_rate), timesheet.total_hours.round(2), price(timesheet.total_bill)]
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