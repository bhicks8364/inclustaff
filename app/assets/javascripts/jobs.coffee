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
    @item.find("[data-behavior='job-in-button']").on "click", @handleIn
    @item.find("[data-behavior='job-out-button']").on "click", @handleOut
  
  handleIn: =>
    $.ajax(
      url: "/admin/jobs/#{@id}/clock_in",
      method: "PATCH"
      dataType: "JSON"
      success: @handleInSuccess
    )

  handleInSuccess: (data) =>
    if data.clocked_in
      @item.find("[data-behavior='job-in-button']").hide()
      @item.find("[data-behavior='job-out-button']").show()
      @item.find("[data-behavior='last-in']").hide()
      @item.find("[data-behavior='last-out']").hide()
      @item.find("[data-behavior='time-in']").html "<strong> In:</strong> #{data.time_in}"
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
      @item.find("[data-behavior='job-out-button']").hide()
      @item.find("[data-behavior='job-in-button']").show()
      @item.find("[data-behavior='time-in']").html "<strong> In:</strong> #{data.time_in}"
      @item.find("[data-behavior='time-out']").html "<strong> Out:</strong> #{data.time_out}"
     
      #@item.find("[data-behavior='shift-state']").html "<span class='label label-danger'>#{data.state}</span>"
      console.log data.state
      console.log data.time_in
      console.log data.time_out
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_out} - #{data.state}")
      console.log data.time_in
      console.log data.time_out
      
      
      
  
      

jQuery ->
  new JobList $("[data-behavior='job-list']")