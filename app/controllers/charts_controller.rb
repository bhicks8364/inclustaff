class ChartsController < ApplicationController
  def paid_invoices
    render json: Invoice.paid.group_by_day(:date_paid).count
  end
end