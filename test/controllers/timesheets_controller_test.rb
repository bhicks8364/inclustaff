# == Schema Information
#
# Table name: timesheets
#
#  id               :integer          not null, primary key
#  job_id           :integer
#  reg_hours        :decimal(, )
#  ot_hours         :decimal(, )
#  gross_pay        :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  state            :string
#  approved_by      :integer
#  shifts_count     :integer
#  total_bill       :decimal(, )
#  invoice_id       :integer
#  approved_by_type :string
#  total_hours      :decimal(, )
#  week             :date
#  reg_bill_rate    :decimal(, )
#  ot_bill_rate     :decimal(, )
#
# Indexes
#
#  index_timesheets_on_approved_by_type  (approved_by_type)
#  index_timesheets_on_deleted_at        (deleted_at)
#  index_timesheets_on_invoice_id        (invoice_id)
#  index_timesheets_on_job_id            (job_id)
#

require 'test_helper'

class TimesheetsControllerTest < ActionController::TestCase
  setup do
    @timesheet = timesheets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:timesheets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create timesheet" do
    assert_difference('Timesheet.count') do
      post :create, timesheet: { gross_pay: @timesheet.gross_pay, job_id: @timesheet.job_id, ot_hours: @timesheet.ot_hours, reg_hours: @timesheet.reg_hours, week: @timesheet.week }
    end

    assert_redirected_to admin_timesheet_path(assigns(:timesheet))
  end

  test "should show timesheet" do
    get :show, id: @timesheet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @timesheet
    assert_response :success
  end

  test "should update timesheet" do
    patch :update, id: @timesheet, timesheet: { gross_pay: @timesheet.gross_pay, job_id: @timesheet.job_id, ot_hours: @timesheet.ot_hours, reg_hours: @timesheet.reg_hours, week: @timesheet.week }
    assert_redirected_to admin_timesheet_path(assigns(:timesheet))
  end

  test "should destroy timesheet" do
    assert_difference('Timesheet.count', -1) do
      delete :destroy, id: @timesheet
    end

    assert_redirected_to admin_timesheets_path
  end
end
