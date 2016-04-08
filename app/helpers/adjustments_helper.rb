
module AdjustmentsHelper
    def is_taxable?(adj)
        if adj.taxable?
            "<i class='fa fa-dollar green' data-toggle='tooltip'  title='Taxable'></i>".html_safe
        else
            "<i class='fa fa-dollar' data-toggle='tooltip'  title='Non-taxable'></i>".html_safe
        end
    end
        
end
