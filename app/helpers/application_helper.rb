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
    def unfollow(user)
        event = @signed_in.events.where(action: "followed", eventable: user).first
        if @signed_in.is_following?(user)
            link_to "<i class='fa fa-user-times red'></i>".html_safe, event, class: "pull-right button small", method: :delete, data: { confirm: "Are you sure?", toggle: "tooltip", position: "right" }, title: "Unfollow"
        end
    end
    def follow(user)
        if @signed_in.is_following?(user)
            "<span class='button' data-placement='top' data-toggle='tooltip' title='Already following #{user.name}'><i class='fa fa-check fa-lg green'></i></span>".html_safe
        else
            if user.company_admin?
                link_to "<span class='button' data-placement='top' data-toggle='tooltip'
                title='Click to follow #{user.name}'><i class='fa fa-street-view fa-lg'></i></span>".html_safe,
                follow_admin_company_admin_path(user), method: :post, remote: true, class: "button"
            elsif user.employee? 
                link_to "<span class='button' data-placement='top' data-toggle='tooltip'
                title='Click to follow #{user.name}'><i class='fa fa-street-view fa-lg'></i></span>".html_safe,
                follow_user_path(user), method: :post, remote: true, class: "button"
                
            elsif user.agency?
                link_to "<span class='button' data-placement='top' data-toggle='tooltip'
                title='Click to follow #{user.name}'><i class='fa fa-street-view fa-lg'></i></span>".html_safe,
                follow_admin_admin_path(user), method: :post, remote: true, class: "button"
            else
                "Idk"
            end
        end
    end
    def link_to_add_fields(name, f, type)
      new_object = f.object.send "build_#{type}"
      id = "new_#{type}"
      fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
        render(type.to_s + "_fields", f: builder)
      end
      link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
    end
    
    def convo_for(options={})
        date = (Time.current.end_of_week + 1.day).stamp("Monday 12/18")
        @header = options[:header]
        @admins = options[:admins]
        @company_admins = options[:company_admins]
        @users = options[:users]
        @type = options[:type]
        @message = options[:message]
        @subject = options[:subject]
        @back_to = options[:back_to]
        if @type == :timesheet_reminder
            @subject = "Timesheet Reminder"
            @message = "Please remember to have all timesheets for last week approved the end of the day on #{date}. Thank you! "
        end
        if admin_signed_in?
            render "admin/conversations/form", users: @users, admins: @admins, company_admins: @company_admins, type: @type, message: @message, subject: @subject
        elsif company_admin_signed_in?
            if @type == :general || @type.nil?
                @admins = Admin.all
                @company_admins = @company.admins.real_users - [current_company_admin]
                @users = @company.users
            end
            render "company/conversations/form", users: @users, admins: @admins, company_admins: @company_admins, type: @type, message: @message, subject: @subject
        elsif user_signed_in?
            render "employee/conversations/form", users: @users, admins: @admins, company_admins: @company_admins, type: @type, message: @message, subject: @subject
        end
    end
    
    
    
end
