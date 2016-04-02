# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  notes                     :text
#  number_needed             :integer
#  needed_by                 :datetime
#  urgent                    :boolean
#  active                    :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  title                     :string
#  deleted_at                :datetime
#  manager_id                :integer
#  jobs_count                :integer
#  account_manager_id        :integer
#  mark_up                   :decimal(, )
#  agency_id                 :integer
#  dt_req                    :string
#  bg_check                  :string
#  heavy_lifting             :boolean
#  stwb                      :boolean
#  est_duration              :string
#  shift                     :string
#  bwc_code                  :string
#  min_pay                   :decimal(, )
#  max_pay                   :decimal(, )
#  pay_frequency             :string
#  address                   :string
#  latitude                  :float
#  longitude                 :float
#  aca_type                  :string
#  education                 :hstore           default({})
#  requirements              :hstore           default({})
#  industry                  :string
#  published_at              :datetime
#  published_by              :integer
#  expires_at                :datetime
#  mobile_time_clock_enabled :boolean          default(FALSE)
#  shift_start               :datetime
#  shift_end                 :datetime
#  account_manager_notes     :text
#  job_description           :text
#  payroll_code              :string
#  status                    :string
#
# Indexes
#
#  index_orders_on_account_manager_id  (account_manager_id)
#  index_orders_on_agency_id           (agency_id)
#  index_orders_on_deleted_at          (deleted_at)
#  index_orders_on_industry            (industry)
#  index_orders_on_manager_id          (manager_id)
#  index_orders_on_published_by        (published_by)
#

require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, order: { active: @order.active, belong_to: @order.belong_to, needed_by: @order.needed_by, notes: @order.notes, number_needed: @order.number_needed, pay_range: @order.pay_range, urgent: @order.urgent }
    end

    assert_redirected_to admin_order_path(assigns(:order))
  end

  test "should show order" do
    get :show, id: @order
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @order
    assert_response :success
  end

  test "should update order" do
    patch :update, id: @order, order: { active: @order.active, belong_to: @order.belong_to, needed_by: @order.needed_by, notes: @order.notes, number_needed: @order.number_needed, pay_range: @order.pay_range, urgent: @order.urgent }
    assert_redirected_to admin_order_path(assigns(:order))
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, id: @order
    end

    assert_redirected_to admin_orders_path
  end
end
