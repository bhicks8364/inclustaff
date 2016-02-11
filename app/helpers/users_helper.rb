module UsersHelper
    def users_tooltip(user)
        "<i class='fa fa-user fa-fw' data-placement='top' data-toggle='tooltip' title=' #{ user.name}'></i>".html_safe
    end
    def user_email(user)
        "<i class='fa fa-mail fa-fw'></i> #{user.email}".html_safe
    end
    
    def check_in(user)
        if user.checked_in_at.present? && user.checked_in_at > Date.today.beginning_of_day
            "<span class='green button' data-placement='top' data-toggle='tooltip' title='Available as of: #{user.checked_in_at.stamp("12/18")} ago'>
              <i class='fa fa-check fa-1x'></i>
            </span>
            ".html_safe
        else
            link_to "<span class='button' data-placement='top' data-toggle='tooltip' title='Update as Available'><i class='fa fa-thumbs-up fa-1x'></i></span>".html_safe, update_as_available_user_path(user), method: :patch, remote: true
            
        end
    end
    def follow(user)
        if admin_signed_in? && !current_admin.is_following?(user)
            link_to "<span class='button' data-placement='top' data-toggle='tooltip' title='Click to follow #{user.name}'><i class='fa fa-street-view fa-lg'></i>	</span>".html_safe, follow_user_path(user), method: :post, remote: true, class: "button"
            
        else
            "<span class='button' data-placement='top' data-toggle='tooltip' title='Already following #{user.name}'><i class='fa fa-street-view fa-lg'></i></span>".html_safe
            
        end
    end
end
