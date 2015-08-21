# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#$(document).on "page:change", ->
    #$('#shifts-button').click ->
        #$('#shifts-table').toggle()
        #


class TimesheetList
  constructor: (item) ->
    @item = $(item)
    @timesheets = $.map @item.find("[data-behavior='timesheet']"), (item, i) ->
      new Timesheet(item)

class Timesheet
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='timesheet-toggle']").on "click", @handleToggle

  handleToggle: =>
    $.ajax(
      url: "/timesheets/#{@id}/approve",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )

  handleToggleSuccess: (data) =>
    if data.approved
      @item.find("[data-behavior='timesheet-state']").html "<span class='label label-success'>#{data.state}</span>"
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-times'></i>     Unapprove"
      @item.find("[data-behavior='approve-user']").html "<p>#{data.user_approved}</p>"
      console.log @item
      console.log data.state
      
    else
      @item.find("[data-behavior='timesheet-state']").html "<span class='label label-primary'>#{data.state}</span>"
      @item.find("[data-behavior='approve-button']").html "<i class='fa fa-check-circle'></i>     Approve"
      @item.find("[data-behavior='approve-user']").html "<p>#{data.user_approved}</p>"
      console.log data.id
      console.log data.state
      

jQuery ->
  new TimesheetList $("[data-behavior='timesheet-list']")
  #$(document).on "ajax:success", (xhr, status, error) ->
      #console.log status.responseText
      #console.log data.id