# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :string
#  first_name             :string
#  last_name              :string
#  deleted_at             :datetime
#  can_edit               :boolean
#  code                   :string
#  address                :string
#  city                   :string
#  state                  :string
#  zipcode                :string
#  employee_id            :integer
#  agency_id              :integer
#  resume_id              :integer
#  checked_in_at          :datetime
#  name                   :string
#  latitude               :float
#  longitude              :float
#  start_date             :date
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#
# Indexes
#
#  index_users_on_agency_id             (agency_id)
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_resume_id             (resume_id)
#  index_users_on_role                  (role)
#

module UsersHelper
    def users_tooltip(user)
        "<i class='fa fa-user fa-fw' data-placement='top' data-toggle='tooltip' title=' #{ user.name}'></i>".html_safe
    end
    def user_email(user)
       user.email
    end
    def user_phone(user)
        @phone = user.employee.phone_number.present? ? user.employee.phone_number : "Unavailable"
        "PH: #{@phone}"
    end
    
    def check_in(user)
        if user.checked_in_at.present? && user.checked_in_at > Date.today.beginning_of_day
            "<span class='green button' data-placement='top' data-toggle='tooltip' title='Available as of: #{user.checked_in_at.stamp("12/18")}'>
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
