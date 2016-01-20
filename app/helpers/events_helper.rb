module EventsHelper
    def event_collaspe(event)
      if event.timesheet?
        "<a class='black' role='button' data-toggle='collapse' href='#collapseEvent_#{event.id}' aria-expanded='false' aria-controls='collapseEvent_#{event.id}'>
          <i class='fa fa-clock-o fa-fw'></i>#{event.eventable_type.humanize} <small> #{event.action.titleize}</small>
        </a>".html_safe
      elsif event.job?
        "<a class='black' role='button' data-toggle='collapse' href='#collapseEvent_#{event.id}' aria-expanded='false' aria-controls='collapseEvent_#{event.id}'>
          <i class='fa fa-briefcase fa-fw'></i>#{event.eventable_type.humanize} <small> #{event.action.titleize}</small>
        </a>".html_safe
      elsif event.follow? && event.admin?
        "<a class='black' role='button' data-toggle='collapse' href='#collapseEvent_#{event.id}' aria-expanded='false' aria-controls='collapseEvent_#{event.id}'>
          <i class='fa fa-user fa-fw'></i>#{event.eventable_type.humanize} <small> #{event.action.titleize}</small>
        </a>".html_safe
      elsif event.follow? && event.user?
        "<a class='black' role='button' data-toggle='collapse' href='#collapseEvent_#{event.id}' aria-expanded='false' aria-controls='collapseEvent_#{event.id}'>
          <i class='fa fa-user green fa-fw'></i>#{event.eventable_type.humanize} <small> #{event.action.titleize}</small>
        </a>".html_safe
      else
        "<a class='black' role='button' data-toggle='collapse' href='#collapseEvent_#{event.id}' aria-expanded='false' aria-controls='collapseEvent_#{event.id}'>
          <i class='fa fa-calendar fa-fw'></i>#{event.eventable_type.humanize} <small> #{event.action.titleize}</small>
        </a>".html_safe
      end
      
    end
end
