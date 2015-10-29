class ChartsController < ApplicationController
  def paid_invoices
    gon.invoices = Invoice.pluck(:total)
    render json: Invoice.all.map{|invoice|
    [invoice.company.name, invoice.total.round(2)]}.chart_json
  end
  def account_managers_ranking
    render json: Admin.account_managers.group(:id).map{|a|
      [a.name, a.current_billing.round(2)]
    }.chart_json
  end
  def recruiter_ranking
    render json: Admin.recruiters.group(:id).map{|a|
      [a.name, a.current_billing.round(2)]
    }.chart_json
  end
  def order_fill_time
    render json: Order.all.map{|a|
      [a.title, a.needed_by, a.jobs.first.try(:created_at)]
    }.chart_json
  end
  
end