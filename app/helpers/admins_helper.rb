module AdminsHelper
    def role_tag(admin)
            "<span class='' data-toggle='tooltip' data-placement='right' title='#{admin.role}'>#{admin.name}</span>".html_safe
    end
end