class NotificationMailer < ApplicationMailer
    def job_notification(account_manager, job)
        @account_manager = account_manager
        @recruiter  = job.recruiter
        @employee = job.employee
        @company = job.company
        mail(to: @account_manager.email, subject: 'New Job Placement!')
    end
end
