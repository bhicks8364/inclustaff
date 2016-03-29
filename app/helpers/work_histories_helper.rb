# == Schema Information
#
# Table name: work_histories
#
#  id            :integer          not null, primary key
#  employee_id   :integer          not null
#  employer_name :string
#  title         :string
#  start_date    :date
#  end_date      :date
#  description   :text
#  current       :boolean          default(FALSE)
#  may_contact   :boolean          default(FALSE)
#  supervisor    :string
#  phone_number  :string
#  pay           :string
#  pay_period    :string
#

module WorkHistoriesHelper
    def may_contact(work_history)
        if work_history.may_contact?
        "<span class=''><i class='fa fa-phone fa-lg' data-toggle='tooltip' data-placement='right' title='This employer may be contacted at #{work_history.phone_number}'></i> </span>".html_safe
        else
        end
    end
    
end
