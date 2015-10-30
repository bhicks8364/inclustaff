class ChartsController < ApplicationController
  def current_weeks_billing
    render json: Timesheet.current_week.order(week: :desc).map{|timesheet|
    [timesheet.company.name, timesheet.total_bill]}.chart_json
  end
  def companies_balance
    gon.invoices = Invoice.pluck(:total)
    render json: Company.with_balance.order(balance: :desc).map{|company|
    [company.name, company.balance]}.chart_json
  end
  def account_managers_ranking
    render json: Admin.account_managers.limit(5).group(:id).map{|a|
      [a.name, a.current_billing.round(2)]
    }.chart_json
  end
  def recruiter_ranking
    render json: Admin.recruiters.limit(5).group(:id).map{|a|
      [a.name, a.current_billing.round(2)]
    }.chart_json
  end
  def order_fill_time
    render json: Order.all.map{|a|
      [a.title, a.needed_by, a.jobs.first.try(:created_at)]
    }.chart_json
  end
  
end