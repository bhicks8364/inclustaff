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
        "<i class='fa fa-user'></i>".html_safe 
      end
  end
  def current_job_status(job)
    if job.declined?
      "Declined"
    else
      job.state
    end
  end
end
