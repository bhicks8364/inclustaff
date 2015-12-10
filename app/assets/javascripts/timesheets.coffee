# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

        


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
      @item.appendTo("#approved");
      @item.find(".conversation-user"). html "<h4 class='text-left'>#{data.name}<span class='label label-success black pull-right'><i class='fa fa-calendar-check-o fa-1x'></i>#{data.state}</span></h4>"
      @item.find("[data-behavior='user-approved']").html "<small>Approved by: #{data.user_approved}</small>"
      @item.find("[data-behavior='timesheet-state']").html "#{data.state}"
      console.log @item
      console.log data.state
    else
      @item.removeClass('item-right').addClass('item-left')
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-square-o fa-stack-2x'></i> <i class='fa fa-check fa-stack-1x'></i>"
      @item.appendTo("#pending");
      @item.find(".conversation-user"). html "<h4 class='text-left'>#{data.name}<span class='label label-danger black pull-right'><i class='fa fa-calendar-times fa-1x'></i>#{data.state}</span></h4>"
      @item.find("[data-behavior='user-approved']").html ""
      @item.find("[data-behavior='timesheet-state']").html "#{data.state}"

    if data.clocked_in
      alert("#{data.name} is currently clocked in. Please clock them out before editing their timesheet.")
      #@item.find("#t-result").html "<button type='button' class='alert alert-danger close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span>#{data.name} is currently clocked in. Please clock them out before approving their timesheet.</button>"
      @item.find("[data-behavior='timesheet-state']").html "#{data.state}"
      #@item.find("[data-behavior='approve-button']").html "<i class='fa fa-check-circle'></i> Approve"
      #@item.find("[data-behavior='approve-user']").html "<p>#{data.user_approved}</p>"
      #@item.find("[data-behavior='approved-circle']").html "<i class='fa fa-square-o fa-2x'></i>"
      console.log data.id
      console.log data.state
      

jQuery ->
  new TimesheetList $("[data-behavior='timesheet-list']")
      
      
      
      
      
      
      
