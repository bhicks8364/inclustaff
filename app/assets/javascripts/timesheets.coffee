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
      $("[data-behavior='timesheet-bg']").removeClass('bg-info').addClass('bg-success')
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-times fa-fw'></i>"
      @item.prependTo("#approved");
      @item.find("[data-behavior='user-approved']").html "<small>Approved by: #{data.user_approved}</small>"
      @item.find("[data-behavior='timesheet-state']").html "#{data.state}"
    else
      $("[data-behavior='timesheet-bg']").removeClass('bg-success').addClass('bg-info')
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-check fa-fw'></i>"
      @item.prependTo("#pending");
      @item.find("[data-behavior='user-approved']").html ""
      @item.find("[data-behavior='timesheet-state']").html "#{data.state}"

    if data.clocked_in
      alert("#{data.name} is currently clocked in. Please clock them out before editing their timesheet.")

jQuery ->
  new TimesheetList $("[data-behavior='timesheet-list']")
      
      
      
      
      
      
      
