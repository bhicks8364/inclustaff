module CommentsHelper
    def link_to_commentable(comment, options = {})
        name = "View #{comment.commentable_type}" 
        signed_in_link_to name, comment.commentable
        # id = comment.commentable_id
        # controller = "#{comment.commentable_type.downcase.pluralize}"
        # path = @signed_in.class.to_s.downcase + "/" + controller
        # link_to name, { controller: path, action: 'show', id: id}, options
    end
    def notify(comment)
        @recruiter = comment.recruiter if comment.account_manager.present?
        @account_manager = comment.account_manager if comment.account_manager.present?
        if @recruiter.present? && @account_manager.present?
            "#{role_tag(@recruiter)} <br> #{role_tag(@account_manager)}".html_safe
        elsif @recruiter.present?
            "#{role_tag(@recruiter)}".html_safe
        elsif @account_manager.present?
            "#{role_tag(@account_manager)}".html_safe
        else
            ""
        end
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
