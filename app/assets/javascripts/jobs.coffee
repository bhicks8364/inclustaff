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
      $("#clocked-in-count").text "#{data.new_count}"
      $("#shift-sym").html "<i class='fa fa-cog fa-spin'></i>"
      @item.find("[data-behavior='time-out']").html "<small>Last Out: #{data.last_out}</small>"
      @item.find("[data-behavior='time-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='shift-state']").html "<strong>#{data.first_name} is now clocked in.</strong><br>"
      $("#clocked-in-nav").show()
    else
      alert("Uh-Oh! Something went wrong! #{data.time_in} - #{data.state}")
    
  handleOut: =>
    $.ajax(
      url: "/admin/jobs/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      $("[data-behavior='job-out-button_#{@id}']").hide()
      $("#in-job-#{@id}").hide()
      $("#shift-sym").html "<i class='fa fa-user'></i>"
      $("[data-behavior='job-in-button_#{@id}']").show()
      $("#clocked-in-count").text "#{data.new_count}"
      @item.find("[data-behavior='time-in']").html "<small><strong> In:</strong> #{data.time_in}</small>"
      @item.find("[data-behavior='time-out']").html "<small><strong> Out:</strong> #{data.time_out}</small>"
      @item.find("[data-behavior='shift-state']").html "<strong>#{data.first_name} is now clocked out.</strong><br>"
      if data.new_count == 0
        $("#clocked-in-nav").hide()
      
    else
      alert("Uh-Oh! Something went wrong! #{data.time_out} - #{data.state}")
      
jQuery ->
  new JobList $("[data-behavior='job-list']")