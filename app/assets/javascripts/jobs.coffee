class JobList
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
    @item.find("[data-behavior='job-in-button_#{@id}']").on "click", @handleIn
    @item.find("[data-behavior='job-out-button_#{@id}']").on "click", @handleOut
  
  handleIn: =>
    $.ajax(
      url: "/admin/jobs/#{@id}/clock_in",
      method: "PATCH"
      dataType: "JSON"
      success: @handleInSuccess
    )

  handleInSuccess: (data) =>
    if data.clocked_in
      $("[data-behavior='job-in-button_#{@id}']").hide()
      $("[data-behavior='job-out-button_#{@id}']").show()
      #@item.find("[data-behavior='job-in-button_#{@id}']").hide()
      #@item.find("[data-behavior='job-out-button_#{@id}']").show()
      @item.find("[data-behavior='time-out']").html "<small>Last Out: #{data.last_out}</small>"
      @item.find("[data-behavior='time-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='shift-state']").html "<strong>CLOCKED IN</strong><br>"
      console.log data.time_in
      console.log data.time_out
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_in} - #{data.state}")
      console.log data.time_in
      console.log data.time_out
    
  handleOut: =>
    $.ajax(
      url: "/admin/jobs/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      
      #@item.find(".shift-item").hide()
      $("[data-behavior='job-out-button_#{@id}']").hide()
      $("[data-behavior='job-in-button_#{@id}']").show()
      #@item.find("[data-behavior='job-in-button']").show()
      @item.find("[data-behavior='time-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='time-out']").html "<small><strong> Out:</strong> #{data.time_out}</small>"
     
      @item.find("[data-behavior='shift-state']").html "<strong>CLOCKED OUT</strong><br>"
      console.log data.state
      console.log data.time_in
      console.log data.time_out
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_out} - #{data.state}")
      console.log data.time_in
      console.log data.time_out
      
      
      
  
      

jQuery ->
  new JobList $("[data-behavior='job-list']")