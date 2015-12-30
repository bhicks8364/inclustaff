module SkillsHelper
    def skills_popover(skills)
        "<span class='black'><i class='fa fa-wrench fa-lg' data-placement='right' data-toggle='tooltip' title='#{skills.map {|p| p.name.titleize}.join(', ') }'></i></span>".html_safe
    end
end
