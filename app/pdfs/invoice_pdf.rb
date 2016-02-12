class InvoicePdf < Prawn::Document
    attr_reader :invoice, :current_agency, :company, :subtotal, :timesheet_data, :view_context
    def initialize(invoice, current_agency, company, subtotal, timesheet_data, view_context)
        super() 
        @invoice = invoice
        @subtotal = subtotal
        @current_agency = current_agency
        @company = company
        @view = view_context
        text "#{helpers.pluralize(12, 'person')}"
        text "For staffing services provided by: #{@current_agency.name }", size: 30, style: :bold, :align => :center, :size => 18
        move_down 30
        text "Invoice Id #:#{@invoice.id }"
        text "for #{@company.name }"
        
        text "#{@recruiter_name}"
        text "Subtotal: #{@view.number_to_currency(@subtotal)}"
    end
    def details
        "Hey details"
    end
    def timesheet_data
        
        move_down 30
        borders = timesheet_data.length - 2
        table(timesheet_data, cell_style: { border_color: 'cccccc' }) do
            cells.padding = 12
            cells.borders = []
            row(0..borders).borders = [:bottom]
        end
    end
   
    def helpers
        ActionController::Base.helpers
    end
end