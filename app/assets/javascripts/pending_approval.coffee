class JobList
  constructor: (item) ->
    @item = $(item)
    @pending_jobs = $.map @item.find("[data-behavior='job']"), (item, i) ->
      new Job(item)

class Job
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='job-toggle']").on "click", @handleToggle
    @item.find("[data-behavior='active-job-cancel']").on "click", @handleCancel

  handleToggle: =>
    $.ajax(
      url: "/admin/jobs/#{@id}/approve",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )
  handleCancel: =>
    $.ajax(
      url: "/admin/jobs/#{@id}/cancel",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleCancel
    )

  handleToggleSuccess: (data) =>
    if data.approved
      @item.find("[data-behavior='job-toggle']").hide
      @item.find("[data-behavior='active-job-cancel']").show
      @item.find("[data-behavior='job-name']").html "<h2>#{data.name}</h2>"
      @item.find("[data-behavior='job-state']").html "<h2>#{data.state}</h2>"
      @item.find("[data-behavior='job-status']").html "<h2>#{data.status}</h2>"
    else
      @item.find("[data-behavior='job-toggle']").hide
      @item.find("[data-behavior='active-job-cancel']").show
      @item.find("[data-behavior='job-name']").html "<h2>#{data.name}</h2>"
      @item.find("[data-behavior='job-status']").html "<h2>#{data.status}</h2>"
      @item.find("[data-behavior='job-state']").html "<h2>#{data.state}</h2>"
  
  handleToggleCancel: (data) =>
    if data.approved
      @item.find("[data-behavior='active-job-cancel']").hide
      @item.find("[data-behavior='job-toggle']").show
      @item.find("[data-behavior='job-end-date']").html "<h2>#{data.ended}</h2>"
      @item.find("[data-behavior='job-status']").html "<h2>#{data.status}</h2>"
      @item.find("[data-behavior='job-state']").html "<h2>#{data.state}</h2>"
    else
      @item.find("[data-behavior='active-job-cancel']").hide
      @item.find("[data-behavior='job-toggle']").show
      @item.find("[data-behavior='job-end-date']").html "<h2>#{data.ended}</h2>"
      @item.find("[data-behavior='job-status']").html "<h2>#{data.status}</h2>"
      @item.find("[data-behavior='job-state']").html "<h2>#{data.state}</h2>"

jQuery ->
  new JobList $("[data-behavior='job-list']")