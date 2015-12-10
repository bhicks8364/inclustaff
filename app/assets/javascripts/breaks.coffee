class TodoList
  constructor: (item) ->
    @item = $(item)
    @shift_breaks = $.map @item.find("[data-behavior='shift_break']"), (item, i) ->
      new Todo(item)

class Todo
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='shift_break-toggle']").on "click", @handleBreakStart

  handleBreakStart: =>
    $.ajax(
      url: "/admin/shifts/#{@id}/break_start",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )

  handleToggleSuccess: (data) =>
    if data.completed
      @item.find("[data-behavior='shift_break-description']").html "<del>#{data.description}</del>"
    else
      @item.find("[data-behavior='shift_break-description']").html data.description

jQuery ->
  new TodoList $("[data-behavior='shift_break-list']")