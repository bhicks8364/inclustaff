module EventsHelper
    def event_collaspe(event)
      "<a class='black' role='button' data-toggle='collapse' href='#collapseEvent_#{event.id}' aria-expanded='false' aria-controls='collapseEvent_#{event.id}'>
        <i class='fa fa-calendar fa-fw'></i>#{event.eventable_type.titleize} <small> #{event.action.titleize}</small>
      </a>".html_safe
    end
end
