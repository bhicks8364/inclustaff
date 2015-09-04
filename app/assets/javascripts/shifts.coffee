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
    @item.find("[data-behavior='out-button']").on "click", @handleOut

    
  handleOut: =>
    $.ajax(
      url: "/admin/shifts/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      alert("Sucessfuly clocked out! #{data.time_out} - #{data.state}")
      console.log data.state
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_out} - #{data.state}")
      
      
  
      
      
      

jQuery ->
  new ShiftList $("[data-behavior='shift-list']")