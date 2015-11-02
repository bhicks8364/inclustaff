class NotificationMailer < ApplicationMailer
    def job_notification(account_manager, job)
        @account_manager = account_manager
        @recruiter  = job.recruiter
        @employee = job.employee
        @company = job.company
        mail(to: @account_manager.email, subject: 'New Job Placement!')
    end
    def new_company(company)
        template_name = "new-company"
        template_content = []
        message = {
            to: [{email: "bhicks8364@gmail.com"}],
            subject: "New Company!",
            merge_vars: [
                {rcpt: "bhicks8364@gmail.com",
                vars: [
                    {name: "COMPANY_NAME", content: company.name}
                    ]
                }
            ]
        }
       
        mandrill_client.messages.send_template(template_name, template_content, message)
    end
end
