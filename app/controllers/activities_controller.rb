class ActivitiesController < ApplicationController
  layout 'admin_layout'
  def index
    @activities = PublicActivity::Activity.all.order(created_at: :desc)
  end

  def show
    @activity = PublicActivity::Activity.find(params[:id])
  end
end
