class Notifications
  constructor: ->
    @events = $("[data-behavior='events']")
    @setup() if @events.length > 0
    console.log(gon.events)
  setup: ->
    $("[data-behavior='events-link']").on "click", @handleClick
    $.ajax(
      url: "/events.json"
      dataType: "JSON"
      method: "GET"
      success: @handleSuccess
    )

  handleClick: (e) =>
    $.ajax(
      url: "/events/mark_as_read"
      dataType: "JSON"
      method: "POST"
      success: ->
        $("[data-behavior='event-count']").text(0)
    )

  handleSuccess: (data) =>
    items = $.map data, (event) ->
      "<a class='dropdown-item' href='#{event.url}'>#{event.state} #{event.action} #{event.eventable}</a>"

    $("[data-behavior='event-count']").text(items.length)
    $("[data-behavior='event-items']").html(items)

jQuery ->
  new Notifications