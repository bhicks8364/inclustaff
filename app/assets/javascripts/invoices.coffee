# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

        


class InvoiceList
  constructor: (item) ->
    @item = $(item)
    
   
    @invoices = $.map @item.find("[data-behavior='invoice']"), (item, i) ->
      new Invoice(item)

class Invoice
  constructor: (item) ->
    @item = $(item)
    
    console.log @item
    console.log @position
    @id   = @item.data("id")
    @setEvents()

  setEvents: ->
    @item.find("[data-behavior='invoice-toggle']").on "click", @handleToggle
    @item.find("[data-behavior='company-invoice-toggle']").on "click", @handleCompanyToggle

  handleToggle: =>
    $.ajax(
      url: "/admin/invoices/#{@id}/mark_as_paid",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )
  handleCompanyToggle: =>
    $.ajax(
      url: "/company/invoices/#{@id}/mark_as_paid",
      method: "PATCH"
      dataType: "JSON"
      success: @handleToggleSuccess
    )

  handleToggleSuccess: (data) =>
    if data.paid
      @item.removeClass('item-left').addClass('item-right')
      @item.find("[data-behavior='invoice-notice']").text "#{data.notice}"
      @item.find("[data-behavior='pay-button']").html "<i class='fa fa-square-o fa-stack-2x'></i> <i class='fa fa-times fa-stack-1x'></i>"
      @item.appendTo("#paid");
      @item.find("[data-behavior='date-paid']").html "#{data.date_paid}"
      @item.find("[data-behavior='invoice-state']").html "<i class='fa fa-check-square-o fa-lg'></i>"
      console.log @item
      console.log data.notice
    else
      @item.find("[data-behavior='invoice-notice']").text "#{data.notice}"
      @item.removeClass('item-right').addClass('item-left')
      @item.find("[data-behavior='pay-button']").html "<i class='fa fa-square-o fa-stack-2x'></i> <i class='fa fa-check fa-stack-1x'></i>"
      @item.find("[data-behavior='invoice-state']").html "<i class='fa fa-times-square-o fa-lg'></i>"
      console.log data.notice
      

jQuery ->
  new InvoiceList $("[data-behavior='invoice-list']")
      
      
      
      
      
      
      
