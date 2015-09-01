jQuery ->
class Timesheet
  constructor: (item) ->
    @item = gon.timesheet
    @id   = @item.data("id")
    @setEvents()
    
    console.log gon.timesheet
    console.log gon.pay
    console.log gon.status
    console.log @item
    