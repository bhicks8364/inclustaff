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

module JobsHelper
  def stored_content
    content_for(:storage) || "<h1>Your storage is empty</h1>".html_safe
  end
  
  def job_sym(job)
      if job.on_break?
        "<i class='fa fa-spinner fa-spin'></i>".html_safe 
      elsif job.on_shift?
        "<i class='fa fa-cog fa-spin'></i>".html_safe 
      else
        "<i class='fa fa-cog'></i>".html_safe 
      end
  end
  def job_class(job)
      if job.on_break?
        "warning" 
      elsif job.declined?
        "danger"
      elsif job.on_shift?
        "success"
      else
        "info"
      end
  end
  def current_job_status(job)
    if job.declined?
      "<span class='text-#{job_class(job)}'>Declined</span>".html_safe
    else
      "<span class='text-#{job_class(job)}'>#{job.state}</span>".html_safe
    end
  end
end
