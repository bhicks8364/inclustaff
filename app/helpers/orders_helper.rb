module OrdersHelper
    include ActsAsTaggableOn::TagsHelper
    
    def skills_popover(order)
        "<i class='fa fa-info-circle fa-lg white' data-toggle='popover' title='#{ order.title_company}' 
        data-content='#{ order.skills.map {|p| p.name.titleize}.join(', ')}'></i>".html_safe
    end
 	
    def status_tag(order)
        if order.urgent? && order.overdue? || order.needs_attention? && order.overdue?
            "<a href='#'><i class='fa fa-exclamation fa-lg'></i></a>".html_safe
        elsif order.needs_attention?
            "UH-OH"
        elsif order.filled?
            "YAY"
        else
            "WTF"
        end
    end
end
