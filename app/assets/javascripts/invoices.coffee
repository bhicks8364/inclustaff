#class InvoiceList
  #constructor: (item) ->
    #@item = $(item)
    #console.log("InvoiceList running...")
   #
    #@invoices = $.map @item.find("[data-behavior='invoice']"), (item, i) ->
      #new Invoice(item)
#
#class Invoice
  #constructor: (item) ->
    #@item = $(item)
    #
    #console.log @item
    #
    #@id   = @item.data("id")
    #@setEvents()
#
  #setEvents: ->
    #@item.find("[data-behavior='invoice-toggle']").on "click", @handleToggle
    #console.log 'click'
  #handleToggle: =>
    #$.ajax(
      #url: "/admin/invoices/#{@id}/mark_as_paid",
      #method: "PATCH"
      #dataType: "JSON"
      #success: @handleToggleSuccess
    #)
#
  #handleToggleSuccess: (data) =>
    #if data.paid
     #
      #@item.hide()
      #
#
      #console.log @item
      #console.log data.state
    #else
      #alert("Uh-oh. Something went wrong.")
      #console.log data.id
      #console.log data.paid
      #
#
#jQuery ->
  #new InvoiceList $("[data-behavior='invoice-list']")
      #
      #
      #
      #
      #
      #
      #
