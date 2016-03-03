class CompanyJobList
  constructor: (item) ->
    @item = $(item)
    @jobs = $.map @item.find("[data-behavior='job']"), (item, i) ->
      new Job(item)
      
class Job
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='code-button_#{@id}']").on "click", @getCode
    @item.find("[data-behavior='job-in-button_#{@id}']").on "click", @handleIn
    @item.find("[data-behavior='job-out-button_#{@id}']").on "click", @handleOut
    
  getCode: =>
    @code = prompt("Please enter your employee code.");
    $.ajax(
      url: "/company/jobs/#{@id}/verify_code",
      data: { code: @code },
      method: "POST"
      dataType: "JSON"
      success: @authorizeClockIn
    )
  authorizeClockIn: (data) =>
    if data.authorized
      @item.find("[data-behavior='code-button_#{@id}']").hide()
      @item.find("[data-behavior='job-in-button_#{@id}']").show()
      @item.find("#verified").html "VERIFIED! You can now clock in."
    else
      @item.find("#unauthorized").html "Sorry that's not right. <br> Please try again or see a manager for help."

  handleIn: =>
    $.ajax(
      url: "/company/jobs/#{@id}/clock_in",
      method: "PATCH"
      dataType: "JSON"
      success: @handleInSuccess
    )

  handleInSuccess: (data) =>
    if data.clocked_in
      @item.prependTo("#clocked_in_list");
      $("[data-behavior='job-in-button_#{@id}']").hide()
      
      @item.find("[data-behavior='time-out']").html "<small>Last Out: #{data.last_out}</small>"
      @item.find("[data-behavior='time-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='shift-state']").html "<strong>#{data.first_name} is now clocked in.</strong><br>"
      @item.find("#verified").html "<strong>#{data.first_name} is now clocked in.</strong><br>"
      console.log data.time_in
      console.log data.time_out
      
      $("#clocked-in-nav").show()
    
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_in} - #{data.state}")
      console.log data.time_in
      console.log data.time_out
    
  handleOut: =>
    $.ajax(
      url: "/company/jobs/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      @item.prependTo("#clocked_out_list");
      #@item.find(".shift-item").hide()
      $("[data-behavior='job-out-button_#{@id}']").hide()
      $("#in-job-#{@id}").hide()
      $("[data-behavior='code-button_#{@id}']").show()
      $("#clocked-in-count").text "#{data.new_count}"
      $(".break-actions-#{@id}").hide()
      @item.find("[data-behavior='time-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='time-out']").html "<small><strong> Out:</strong> #{data.time_out}</small>"
      @item.find("[data-behavior='shift-state']").html "<strong>#{data.first_name} is now clocked out.</strong><br>"
      if data.new_count == 0
        $("#clocked-in-nav").hide()
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_out} - #{data.state}")
      console.log data.time_in
      console.log data.time_out
      
      
      
  
      

jQuery ->
  new CompanyJobList $("[data-behavior='company-job-list']")