# == Schema Information
#
# Table name: jobs
#
#  id               :integer          not null, primary key
#  employee_id      :integer
#  order_id         :integer
#  title            :string
#  description      :string
#  start_date       :date
#  pay_rate         :decimal(, )
#  end_date         :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active           :boolean
#  deleted_at       :datetime
#  recruiter_id     :integer
#  timesheets_count :integer
#  settings         :hstore
#  pay_types        :text             is an Array
#  vacation         :hstore
#  state            :string           default("Pending Approval")
#
# Indexes
#
#  index_jobs_on_deleted_at    (deleted_at)
#  index_jobs_on_pay_types     (pay_types)
#  index_jobs_on_recruiter_id  (recruiter_id)
#

require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  setup do
    @job = jobs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job" do
    assert_difference('Job.count') do
      post :create, job: { belongs_to: @job.belongs_to, description: @job.description, end_date: @job.end_date, pay_rate: @job.pay_rate, start_date: @job.start_date, title: @job.title }
    end

    assert_redirected_to job_path(assigns(:job))
  end

  test "should show job" do
    get :show, id: @job
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @job
    assert_response :success
  end

  test "should update job" do
    patch :update, id: @job, job: { belongs_to: @job.belongs_to, description: @job.description, end_date: @job.end_date, pay_rate: @job.pay_rate, start_date: @job.start_date, title: @job.title }
    assert_redirected_to job_path(assigns(:job))
  end

  test "should destroy job" do
    assert_difference('Job.count', -1) do
      delete :destroy, id: @job
    end

    assert_redirected_to jobs_path
  end
end
