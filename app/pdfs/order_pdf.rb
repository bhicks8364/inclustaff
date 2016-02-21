class OrderPdf < Prawn::Document
    def initialize(order, current_agency, min_pay, view_context)
        super()
        @order = order
        @min_pay = min_pay
        @current_agency = current_agency
        @view = view_context
        text "#{order.company.name }", size: 30, style: :bold
        move_down 30
        text "#{order.notes }"
        text "#{current_agency.name }"
        text default_message
    end
    private
    def default_message
        "#{@view.number_to_currency(@min_pay)}"
        
    end
end