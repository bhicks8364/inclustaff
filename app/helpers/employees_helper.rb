module EmployeesHelper
    def emp_popover(employee)
        "<i class='fa fa-tag white' data-toggle='popover' title='#{ employee.name}' 
        data-content='#{ employee.skills.map {|p| p.name.titleize}.join(', ')}'></i>".html_safe
    end
end
