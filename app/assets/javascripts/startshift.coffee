

change_visibility = (state) ->
  if state == "Clocked Out"
    $(".clocked-out").show()
  else
    $(".clocked-out").hide()

jQuery ->
  change_visibility $("#timesheet_shift_state :selected").text()
  $("#timesheet_shift_state").on "change", (e) ->
    change_visibility $(this).find(":selected").text()
    
  change_visibility $("#shift_state :selected").text()
  $("#shift_state").on "change", (e) ->
    change_visibility $(this).find(":selected").text()
