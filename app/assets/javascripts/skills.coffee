class SkillList
  constructor: (item) ->
    @item = $(item)
    @skills = $.map @item.find("[data-behavior='skill']"), (item, i) ->
      new Skill(item)
      
class Skill
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='skill-in-button_#{@id}']").on "click", @handleIn
    @item.find("[data-behavior='skill-out-button_#{@id}']").on "click", @handleOut
  
  handleIn: =>
    $.ajax(
      url: "/admin/skills/#{@id}/clock_in",
      method: "PATCH"
      dataType: "JSON"
      success: @handleInSuccess
    )

  handleInSuccess: (data) =>
    if data.clocked_in
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
      url: "/admin/skills/#{@id}/clock_out",
      method: "PATCH"
      dataType: "JSON"
      success: @handleOutSuccess
    )

  handleOutSuccess: (data) =>
    if data.clocked_out
      
      #@item.find(".shift-item").hide()
      $("[data-behavior='skill-out-button_#{@id}']").hide()
      $("[data-behavior='skill-in-button_#{@id}']").show()
      #@item.find("[data-behavior='skill-in-button']").show()
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
  new SkillList $("[data-behavior='skill-list']")