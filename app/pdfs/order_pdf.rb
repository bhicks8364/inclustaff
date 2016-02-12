class OrderPdf < Prawn::Document
    def initialize(order, current_agency, min_pay, view_context)
        super()
        @order = order
        @min_pay = min_pay
        @current_agency = current_agency
        @view = view_context
        text "Hey there! #{current_agency.name }", size: 30, style: :bold
        text "Hey there! #{current_agency.name }"
        text "Hey there! #{current_agency.name }"
        text default_message
    end
    private
    def default_message
        "#{@view.number_to_currency(@min_pay)}"
        
    end
end