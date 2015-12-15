module OrdersHelper
    include ActsAsTaggableOn::TagsHelper
    
    def skills_popover(order)
        "<i class='fa fa-info-circle' data-placement='right' data-trigger='focus' data-toggle='popover' title='#{ order.title_company}' 
        data-content='#{ order.skills.map {|p| p.name.titleize}.join(', ')}'></i>".html_safe
    end
    def info_popover(order)
        "<span class='black'><i class='fa fa-user' data-placement='top' data-toggle='popover' title='#{ order.title_company}' 
        data-content='Account Manager: #{ order.account_manager.name}'></i></span>".html_safe
    end
    def matching_emp_popover(order)
        "<i class='fa fa-users' data-toggle='popover' data-placement='top' title='#{ order.matching_employees.count} Matching Candidates' 
        data-content='#{ order.matching_employees.map {|p| p.name.titleize}.join(', ')}'></i>".html_safe
    end
   
    def status_tag(order)
        if order.urgent? && order.overdue? || order.needs_attention? && order.overdue?
            "<i class='fa fa-exclamation fa-fw red'></i>".html_safe
        elsif order.needs_attention?
            "<i class='fa fa-exclamation-circle fa-fw'></i>".html_safe
        elsif order.filled?
            "<i class='fa fa-exclamation fa-fw'></i>".html_safe
        else
            "<i class='fa fa-exclamation fa-fw'></i>".html_safe
        end
    end
end
