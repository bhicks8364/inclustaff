class JobList
  constructor: (item) ->
    @item = $(item)
    @jobs = $.map @item.find("[data-behavior='empjob']"), (item, i) ->
      new Job(item)
      
class Job
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='empjob-in-button_#{@id}']").on "click", @handleIn
    @item.find("[data-behavior='empjob-out-button_#{@id}']").on "click", @handleOut
  
  handleIn: =>
    $.ajax(
      url: "/employee/jobs/#{@id}/clock_in",
      method: "PATCH"
      dataType: "JSON"
      success: @handleInSuccess
    )

  handleInSuccess: (data) =>
    if data.clocked_in
      $("[data-behavior='empjob-in-button_#{@id}']").hide()
      $("[data-behavior='empjob-out-button_#{@id}']").show()
      #@item.find("[data-behavior='job-in-button_#{@id}']").hide()
      #@item.find("[data-behavior='job-out-button_#{@id}']").show()
      @item.find("[data-behavior='emptime-out']").html "<small>Last Out: #{data.last_out}</small>"
      @item.find("[data-behavior='emptime-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='empshift-state']").html "<strong>#{data.first_name} is now clocked in.</strong><br>"
      console.log data.time_in
      console.log data.time_out
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_in} - #{data.state}")
      console.log data.time_in
      console.log data.time_out
    
  handleOut: =>
    $.ajax(
      url: "/employee/jobs/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      
      #@item.find(".shift-item").hide()
      $("[data-behavior='empjob-out-button_#{@id}']").hide()
      $("[data-behavior='empjob-in-button_#{@id}']").show()
      #@item.find("[data-behavior='empjob-in-button']").show()
      @item.find("[data-behavior='emptime-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='emptime-out']").html "<small><strong> Out:</strong> #{data.time_out}</small>"
     
      @item.find("[data-behavior='empshift-state']").html "<strong>#{data.first_name} is now clocked out.</strong><br>"
      console.log data.state
      console.log data.time_in
      console.log data.time_out
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_out} - #{data.state}")
      console.log data.time_in
      console.log data.time_out
      
      
      
  
      

jQuery ->
  new JobList $("[data-behavior='empjob-list']")