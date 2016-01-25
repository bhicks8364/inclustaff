class TimesheetList
  constructor: (item) ->
    @item = $(item)
    @timesheets = $.map @item.find("[data-behavior='timesheet']"), (item, i) ->
      new Timesheet(item)

class Timesheet
  constructor: (item) ->
    @item = $(item)
    
    console.log @item
    console.log @position
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='timesheet-toggle']").on "click", @handleToggle
    @item.find("[data-behavior='company-timesheet-toggle']").on "click", @handleCompanyToggle

  handleToggle: =>
    $.ajax(
      url: "/admin/timesheets/#{@id}/approve",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )
  handleCompanyToggle: =>
    $.ajax(
      url: "/company/timesheets/#{@id}/approve",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )

  handleToggleSuccess: (data) =>
    if data.approved
      @item.removeClass('item-left').addClass('item-right')
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-square-o fa-stack-2x'></i> <i class='fa fa-times fa-stack-1x'></i>"
      @item.prependTo("#approved");
      @item.find("[data-behavior='user-approved']").html "<small>Approved by: #{data.user_approved}</small>"
      @item.find("[data-behavior='timesheet-state']").html "#{data.state}"
    else
      @item.removeClass('item-right').addClass('item-left')
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-square-o fa-stack-2x '></i>  <i class='fa fa-check fa-stack-1x'></i>"
      @item.prependTo("#pending");
      @item.find("[data-behavior='user-approved']").html ""
      @item.find("[data-behavior='timesheet-state']").html "#{data.state}"

    if data.clocked_in
      alert("#{data.name} is currently clocked in. Please clock them out before editing their timesheet.")

jQuery ->
  new TimesheetList $("[data-behavior='timesheet-list']")
      
      
      
      
      
      
      
