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
        
        text "#{helpers.pluralize(@invoice.timesheets.count, 'person')}"
        text "For staffing services provided by: #{@current_agency.name }", size: 30, style: :bold, :align => :center, :size => 18
        move_down 30
        text "Invoice Id #:#{@invoice.id }"
        move_down 30
        text "Invoice for #{@company.name }"
        move_down 30
        timesheets
        move_down 80
        words
        move_down 80
        text "Subtotal: #{@view.number_to_currency(@subtotal)}"
    end
    def details
        "Hey details"
    end
    def timesheets
        move_down 30
        borders = timesheets2.length - 2
        table(timesheets2, cell_style: { border_color: 'cccccc' }) do
            row(0).font_style = :bold
            cells.padding = 12
            cells.borders = []
            row(0..borders).borders = [:bottom]
        end
    end
    def timesheets2
        @invoice.timesheets.map do |timesheet|
            [timesheet.employee.name, price(timesheet.gross_pay), price(timesheet.total_bill)]
        end
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