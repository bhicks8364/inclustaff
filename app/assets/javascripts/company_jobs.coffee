console.log(gon.on_break_shifts)
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
      @item.find("#unauthorized").html("")
      if data.clocked_in
        @item.find("[data-behavior='code-button_#{@id}']").hide().delay(5000).show(0)
        
        # @item.find("#break-buttons").show()
        @item.find(".clock-actions-#{@id}").show(0).delay(5000).hide(0)
      else
        @item.find("[data-behavior='code-button_#{@id}']").hide().delay(5000).show(0)
        @item.find(".clock-actions-#{@id}").show(0).delay(5000).hide(0)
        @item.find("#verified").html("Welcome back, #{data.first_name}! You can now clock in.").delay(5000).hide(0)
    else
      @item.find("#unauthorized").html("Sorry that's not right. <br> Please try again or see a manager for help.").delay(5000).hide(0)

  handleIn: =>
    $.ajax(
      url: "/company/jobs/#{@id}/clock_in",
      method: "PATCH"
      dataType: "JSON"
      success: @handleInSuccess
    )

  handleInSuccess: (data) =>
    if data.clocked_in
      @item.appendTo("#clocked_in_list")
      @item.find(".clock-actions-#{@id}").hide()
      @item.find("[data-behavior='code-button_#{@id}']").show()
      @item.find("#verified").html "<small><strong> In:</strong> #{data.time_in}</small>"
      $("#clocked-in-nav").show()
    else
      @item.find("#unauthorized").text("Uh-Oh! Something went wrong! #{data.state}")
      
  handleOut: =>
    $.ajax(
      url: "/company/jobs/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      @item.appendTo("#clocked_out_list")
      @item.find("[data-behavior='code-button_#{@id}']").show()
      @item.find(".clock-actions-#{@id}").hide()
      @item.find("#unauthorized").hide()
      @item.find("#verified").html "<small><strong> Out:</strong> #{data.time_in}</small>"
      $("#clocked-in-count").text "#{data.new_count}"
      if data.new_count == 0
        $("#clocked-in-nav").hide()
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_out} - #{data.state}")

jQuery ->
  new CompanyJobList $("[data-behavior='company-job-list']")
  