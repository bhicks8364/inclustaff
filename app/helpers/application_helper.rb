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
        if title.present?
            title += " | " 
            title += "Inclustaff"
        else
            "IncluStaff"
        end
    end
    
    def custom_form_for(object, *args, &block)
      options = args.extract_options!
      simple_form_for(object, *(args << options.merge(builder: CustomFormBuilder)), &block)
    end
    
    def tag_link(taggable)
        highlight(taggable.tag_list.to_s, ActsAsTaggableOn::Tag.all.map(&:name), highlighter: '<a href="/tags?tag=\1">\1</a>'.html_safe)
    end
    
    def tag_popover(taggable)
        
        "<span class='black'><i class='fa fa-tag' data-placement='right' data-toggle='popover' title='Tags for #{ taggable.try(:title) || taggable.try(:first_name)}' 
        data-content='#{ taggable.tag_list }'></i></span>".html_safe
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
    
    def embed(youtube_url)
        youtube_id = youtube_url.split("=").last
        content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
    end
    def gravatar_for(user, options = { size: 80 })
        gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
        size = options[:size]
        gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
        image_tag(gravatar_url, alt: user.name, class: "gravatar")
    end
end
