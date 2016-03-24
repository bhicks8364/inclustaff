# == Schema Information
#
# Table name: employees
#
#  id               :integer          not null, primary key
#  first_name       :string
#  last_name        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  email            :string
#  ssn              :string
#  phone_number     :string
#  user_id          :integer
#  deleted_at       :datetime
#  assigned         :boolean
#  resume_id        :string
#  desired_job_type :string
#  desired_shift    :string
#  availability     :hstore
#  dns              :boolean          default(FALSE)
#  exsisting_hours  :decimal(, )      default(0.0)
#  aca_hours        :decimal(, )      default(0.0)
#  status           :string           default("New")
#
# Indexes
#
#  index_employees_on_availability  (availability)
#  index_employees_on_deleted_at    (deleted_at)
#  index_employees_on_email         (email)
#  index_employees_on_user_id       (user_id)
#

module EmployeesHelper
    def employee_collaspe(employee)
      "<a class='black' role='button' data-toggle='collapse' href='#collapseEmployee_#{employee.id}' aria-expanded='false' aria-controls='collapseEmployee_#{employee.id}'>
        <i class='fa fa-user fa-fw'></i><small>#{employee.current_job.try(:name_title) || employee.try(:name)}</small>
      </a>".html_safe
    end
    def emp_popover(employee)
        "<span class='' data-toggle='tooltip' 
        title='#{ employee.skills.map {|p| p.name.titleize}.join(', ')}'>#{employee.name}</span>".html_safe
    end
    def aca_progress(employee_hours, eligiblity_hours)
            x = (employee_hours / eligiblity_hours * 100).round(2)
            if x < 70
                color = "danger"
            elsif x >= 70 && x < 100
                color = "warning"
            elsif x >= 100
                color = "success"
            end
          "<div class='progress'><div class='progress-bar progress-bar-#{color}' role='progressbar' aria-valuenow='#{ x }' aria-valuemin='0' aria-valuemax='100' style='width: #{x}%; max-width: 100%;'>
              <spn class='black'><strong>#{ x >= 100 ? "Eligible" : "Not Eligible" }</strong>  #{x}% </span>
          </div></div>".html_safe
    end
    def aca_for(employee)
        employee_hours = employee.total_hours
        eligiblity_hours = 1560
            x = (employee_hours / eligiblity_hours * 100).round(2)
            if x < 70
                color = "danger"
            elsif x >= 70 && x < 100
                color = "warning"
            elsif x >= 100
                color = "success"
            end
          "<div class='progress'><div class='progress-bar progress-bar-#{color}' role='progressbar' aria-valuenow='#{ x }' aria-valuemin='0' aria-valuemax='100' style='width: #{x}%; max-width: 100%;'>
              <spn class='black'><strong>#{ x >= 100 ? "Eligible" : "Not Eligible" }</strong>  #{x}% </span>
          </div></div>".html_safe
    end
end
