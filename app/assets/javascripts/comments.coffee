class CommentList
  constructor: (item) ->
    @item = $(item)
    @comments = $.map @item.find("[data-behavior='comment']"), (item, i) ->
      new Comment(item)

class Comment
  constructor: (item) ->
    @item = $(item)
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='comment-toggle']").on "click", @handleToggle
    

  handleToggle: =>
    $.ajax(
      url: "/comments/#{@id}/mark_as_read",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )
  
  handleToggleSuccess: (data) =>
    if data.read
      # @item.addClass('comment')
      @item.find("[data-behavior='comment-state']").html "#{data.state}"
      # @item.find("#comment_form").hide()
      @item.find("[data-behavior='read-button']").html "<i class='fa fa-check-square-o fa-1x'></i>"
      @item.prependTo("[data-behavior='read-comment-list']")
      
      $("[data-behavior='comments-count']").text "#{data.new_count}"
      console.log @item
      console.log data.state
      if data.new_count == 0
        $("#comments-nav").hide()
    else
      @item.find("[data-behavior='comment-state']").html "#{data.state}"
      @item.find("[data-behavior='read-button']").html "<i class='fa fa-square-o fa-1x'></i>"
      @item.prependTo("#unread")


jQuery ->
  new CommentList $("[data-behavior='comment-list']")
