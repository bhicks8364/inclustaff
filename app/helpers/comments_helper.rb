module CommentsHelper
    def link_to_commentable(comment, options = {})
        name = "View #{comment.commentable_type}" 
        id = comment.commentable_id
        controller = "#{comment.commentable_type.downcase.pluralize}"
        path = @signed_in.class.to_s.downcase + "/" + controller
        link_to name, { controller: path, action: 'show', id: id}, options
    end
    def selected_recipient(recipient_type, recipient_id)
        @recipient ||=   case recipient_type
                when "Admin"
                    Admin.find(recipient_id)
                when "CompanyAdmin"
                    CompanyAdmin.find(recipient_id)
                when "Employee"
                    User.find(recipient_id)
            end
        
    end
end
