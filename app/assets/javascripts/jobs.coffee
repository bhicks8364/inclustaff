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
    @item.find("[data-behavior='job-button']").on "click", @handleOut
    
  handleOut: =>
    $.ajax(
      url: "/jobs/#{@id}/clock_in",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      @item.find("[data-behavior='out-time']").html " <strong>Out:</strong> #{data.time_in}"
      @item.find("[data-behavior='job-state']").html "<span class='label label-default'>#{data.state}</span>"
      console.log data.state
      
    else
#
      #@item.find("[data-behavior='job-button']").html "<i class='fa fa-sign-out red fa-lg''></i>"
      #@item.find("[data-behavior='job-state']").html "<span class='label label-success'>#{data.state}</span>"
      #@item.find("[data-behavior='in-time']").html "<strong>In:</strong> #{data.time_in}"
      console.log data.state
      console.log data.time_in
      alert("new job created! #{data.time_in}")
      

jQuery ->
  new JobList $("[data-behavior='job-list']")