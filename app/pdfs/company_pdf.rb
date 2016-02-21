class CompanyPdf < Prawn::Document
    attr_reader :company, :signed_in, :current_agency, :view_context, :pdf_type
    def initialize(company, signed_in, current_agency, view_context, pdf_type)
        super()
        @company = company
        @pdf_orders = @company.orders
        @signed_in = signed_in
        @current_agency = current_agency
        @view = view_context
        
        text default_message
        move_down 30
        order_table
    end
    private
    def default_message
        "#{@company.name }"
    end
    def order_table
        move_down 10
        
        borders = order_rows.length - 2
        table(order_rows,  :row_colors => ["F0F0F0", "FFFFCC"], :position => :center, cell_style: { border_color: 'cccccc' }) do
            # row(0).font_style = :bold
            cells.padding = 8
            cells.borders = []
            row(0..borders).borders = [:bottom]
        end
        
    end
    def order_rows
        total = 0
       
            @t = [["Status","Industry", "Title", "Mark Up", "Account Manager"]]
            @pdf_orders.map do |order|
               @t <<  [order.status, order.industry, order.open_jobs, order.mark_up, order.account_manager.name]
                total += order.mark_up
            end
            avg = total / @pdf_orders.count
            @t << ["", "", "", "Average mark up", avg.round(2)]
            @t
            
    end
    def price(number)
        @view.number_to_currency(number)
    end
    
end