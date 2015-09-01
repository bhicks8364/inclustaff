class ShiftList
  constructor: (item) ->
    @item = $(item)
    @shifts = $.map @item.find("[data-behavior='shift']"), (item, i) ->
      new Shift(item)
      
class Shift
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='shift-button']").on "click", @handleOut
    
  handleOut: =>
    $.ajax(
      url: "/admin/shifts/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      @item.find("[data-behavior='out-time']").html " <strong>Out:</strong> #{data.time_in}"
      @item.find("[data-behavior='shift-state']").html "<span class='label label-default'>#{data.state}</span>"
      console.log data.state
      
    else
#
      #@item.find("[data-behavior='shift-button']").html "<i class='fa fa-sign-out red fa-lg''></i>"
      #@item.find("[data-behavior='shift-state']").html "<span class='label label-success'>#{data.state}</span>"
      #@item.find("[data-behavior='in-time']").html "<strong>In:</strong> #{data.time_in}"
      console.log data.state
      console.log data.time_in
      alert("new shift created! #{data.time_in}")
      

jQuery ->
  new ShiftList $("[data-behavior='shift-list']")