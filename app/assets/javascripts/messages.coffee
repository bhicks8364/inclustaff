change_visibility = (recipient_type) ->
  if recipient_type == "Admin"
    $(".admin-recipient").show()
    $(".company-admin-recipient").hide()
    $(".employee-recipient").hide()
  else if recipient_type == "CompanyAdmin"
    $(".company-admin-recipient").show()
    $(".admin-recipient").hide()
    $(".employee-recipient").hide()
  else if recipient_type == "Employee"
    $(".employee-recipient").show()
    $(".admin-recipient").hide()
    $(".company-admin-recipient").hide()
  else
    $(".new-recipient").show()
    $(".employee-recipient").hide()
    $(".admin-recipient").hide()
    $(".company-admin-recipient").hide()
change_visibility2 = (recipient_id) ->
  console.log(this)
  # if recipient_type == "Admin"
  #   $(".admin-recipient").show()
  #   $(".company-admin-recipient").hide()
  #   $(".employee-recipient").hide()
  # else if recipient_type == "CompanyAdmin"
  #   $(".company-admin-recipient").show()
  #   $(".admin-recipient").hide()
  #   $(".employee-recipient").hide()
  # else if recipient_type == "Employee"
  #   $(".employee-recipient").show()
  #   $(".admin-recipient").hide()
  #   $(".company-admin-recipient").hide()
  # else
  #   $(".new-recipient").show()
  #   $(".employee-recipient").hide()
  #   $(".admin-recipient").hide()
  #   $(".company-admin-recipient").hide()
    
# # change_recipient = (recipient_type) ->
# #     if recipient_type == "Admin"
# #     $(".admin-recipient").show()
# #     $(".company-admin-recipient").hide()
# #     $(".employee-recipient").hide()
# #   else if recipient_type == "CompanyAdmin"
# #     $(".company-admin-recipient").show()
# #     $(".admin-recipient").hide()
# #     $(".employee-recipient").hide()
# #   else if recipient_type == "Employee"
# #     $(".employee-recipient").show()
# #     $(".admin-recipient").hide()
# #     $(".company-admin-recipient").hide()
# #   else
# #     $(".new-recipient").show()
# #     $(".employee-recipient").hide()
# #     $(".admin-recipient").hide()
# #     $(".company-admin-recipient").hide()
    
# # jQuery ->
# #   change_visibility $("#comment_recipient_type :selected").text()
# #   $("#comment_recipient_type").on "change", (e) ->
# #     change_visibility $(this).find(":selected").text()
    
# @recipient_id = $("#comment_recipient_id :selected").text()

# jQuery ->
#     change_visibility $("#shift_state :selected").text()
#     $("#shift_state").on "change", (e) ->
#     change_visibility $(this).find(":selected").text()
#     console.log(gon.recipient_name)
#     console.log(gon.recipient_id)
#     console.log(gon.recipient_type)
#     console.log(gon.param_type)

jQuery ->
  change_visibility $("#comment_recipient_type :selected").text()
  $("#comment_recipient_type").on "change", (e) ->
    change_visibility $(this).find(":selected").text()
    console.log(this)
    
    
  change_visibility2 $("#comment_recipient_id :selected").text()
  $("#comment_recipient_id").on "change", (e) ->
    change_visibility2 $(this).find(":selected").text()
    console.log(this)


