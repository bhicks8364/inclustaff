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

  handleToggle: =>
    $.ajax(
      url: "/admin/timesheets/#{@id}/approve",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )

  handleToggleSuccess: (data) =>
    if data.approved
      @item.removeClass('item-left').addClass('item-right')
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-square-o fa-stack-2x'></i><i class='fa fa-times fa-stack-1x'></i>"
      #@item.find("[data-behavior='approve-user']").html "<p>#{data.user_approved}</p>"
      #@item.find("[data-behavior='approved-circle']").html "<i class='fa fa-check-square-o fa-2x'></i>"
      
      console.log @item
      console.log data.state
    else
      @item.removeClass('item-right').addClass('item-left')
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-square-o fa-stack-2x'></i><i class='fa fa-check fa-stack-1x'></i>"
      #@item.find("[data-behavior='approved-circle']").html "<i class='fa fa-square-o fa-2x'></i>"
      

    if data.clocked_in
      alert("#{data.name} is currently clocked in. Please clock them out before editing their timesheet.")
      #@item.find("#t-result").html "<button type='button' class='alert alert-danger close' data-dismiss='alert' aria-label='Close'><span aria-hidden='true'>&times;</span>#{data.name} is currently clocked in. Please clock them out before approving their timesheet.</button>"
      #@item.find("[data-behavior='timesheet-state']").html "<span class='label label-primary'>#{data.state}</span>"
      #@item.find("[data-behavior='approve-button']").html "<i class='fa fa-check-circle'></i> Approve"
      #@item.find("[data-behavior='approve-user']").html "<p>#{data.user_approved}</p>"
      #@item.find("[data-behavior='approved-circle']").html "<i class='fa fa-square-o fa-2x'></i>"
      console.log data.id
      console.log data.state
      

jQuery ->
  new TimesheetList $("[data-behavior='timesheet-list']")
      
      
      
      
      
      
      
