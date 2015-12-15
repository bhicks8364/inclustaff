module ApplicationHelper
    require 'html/pipeline'
    def markdownify(content)
        pipeline_context = {gfm: true}
        pipeline = HTML::Pipeline.new [
            HTML::Pipeline::MarkdownFilter,
            HTML::Pipeline::SanitizationFilter,
            HTML::Pipeline::MentionFilter
        ], pipeline_context
        pipeline.call(content)[:output].to_s.html_safe
    end
    def page_title(title)
        title += " | " if title.present?
        title += "Inclustaff"
    end
    
    def signed_in_link_to(name, model, options = {})
        if @signed_in.class.to_s == "CompanyAdmin"
            @path = "company"
        elsif admin_signed_in?
            @path = "admin"
        elsif user_signed_in?
            @path = "employee"
        end
        # name = "View #{model.class.to_s}" 
        id = model.id
        controller = "#{model.class.to_s.downcase.pluralize}"
        
        path = @path + "/" + controller
        # options[:class] ? options[:class] += ' pjax' : options[:class] = 'pjax'
        link_to name, { controller: path, action: 'show', id: id}, options
    end
end
