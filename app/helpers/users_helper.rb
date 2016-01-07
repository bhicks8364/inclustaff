module UsersHelper
    def users_tooltip(user)
        "<i class='fa fa-user' data-placement='right' data-toggle='tooltip' title=' #{ user.name}'></i>".html_safe
    end
    def check_in(user)
        if user.checked_in_at.present? && user.checked_in_at > Date.today.beginning_of_day
            "<span class='fa-stack fa-lg' data-placement='right' data-toggle='tooltip' title='Checked in #{time_ago_in_words(user.checked_in_at)} ago'>
              <i class='fa fa-square-o fa-stack-2x'></i>
              <i class='fa fa-check fa-stack-1x'></i>
            </span>
            ".html_safe
        else
            link_to "<span class='fa-stack fa-lg' data-placement='right' data-toggle='tooltip' title='Update as Available'><i class='fa fa-square-o fa-stack-2x'></i><i class='fa fa-thumbs-up fa-stack-1x'></i></span>".html_safe, update_as_available_user_path(user), method: :patch, remote: true
            
        end
    end
end
