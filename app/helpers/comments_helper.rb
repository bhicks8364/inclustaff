module CommentsHelper
    def link_to_commentable(comment, options = {})
        name = "View #{comment.commentable_type}" 
        id = comment.commentable_id
        controller = "#{comment.commentable_type.downcase.pluralize}"
        path = @signed_in.class.to_s.downcase + "/" + controller
        options[:class] ? options[:class] += ' pjax' : options[:class] = 'pjax'
        link_to name, { controller: path, action: 'show', id: id}, options
    end
    def selected_recipient(recipient_type, recipient_id)
        case recipient_type
        when "Admin"
            r = Admin.find(recipient_id)
        when "CompanyAdmin"
            r = CompanyAdmin.find(recipient_id)
        when "Employee"
            r = User.find(recipient_id)
        end
        r.name
    end
end
