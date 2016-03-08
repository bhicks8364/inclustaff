class CompanyAgreementPdf < Prawn::Document
    attr_reader :company, :signed_in, :current_agency, :view_context, :pdf_type
    def initialize(company, signed_in, current_agency, view_context, pdf_type)
        super()
        @company = company
        @pdf_orders = @company.orders
        @signed_in = signed_in
        @current_agency = current_agency
        @view = view_context

        text "<color rgb='a6a6a6'>Company ID ##{@company.id}</color>", inline_format: true, font: "Courier"
        y_position = cursor + 30
        image open(logo), height: 48, position: :center
        move_down 25
        text "Agreement between #{@current_agency.name } and #{@company.name}", :color => "a6a6a6", inline_format: true, align: :center, size: 18
        move_down 20
        
        agreement
        move_down 20
        
        travel
        move_down 15
        text "TEMPORARY TO HIRE:"
        move_down 5
        early_release
        move_down 15
        text "TEMPORARY EARLY RELEASE:"
        move_down 5
        temporary_agreement
        move_down 15
        text invoice_info
        move_down 20
        text "THIS DOES NOT APPLY TO CLIENT IDENTIFIED CANDIDATES", :color => "a6a6a6", align: :right, size: 8


    end
    def logo
        Rails.root.join("app/assets/images/incluStaff_twitter_logo.png")
    end
    def agreement
        text "#{@company.name} will be invoiced on a weekly basis for hours worked by #{@current_agency.name}’s Candidate. #{@current_agency.name.upcase} will not be responsible for any claims resulting from any #{@company.name} violation of these provisions. #{@company.name} will defend and   indemnify #{@current_agency.name} and hold it harmless, from any claims arising from, or related to, the #{@company.name}’s violation of these provisions.",
        valign: :top, leading: 5, size: 12
    end
    def travel
        text "Client Company shall not request Candidate to travel off-site for  business purposes or operate machinery/motor vehicles without prior notification to #{@current_agency.name} #{@company.name} must also notify #{@current_agency.name} prior to changing the Candidate’s pre-agreed duties."
    end
    
    def title2
        "AGREEMENT BETWEEN  #{@current_agency.name} AND  #{@company.name} IF #{@current_agency.name.upcase}'s CANDIDATE IS PUT ON CLIENT’S  PAYROLL "
    end
    def invoice_info
        "Invoices are due upon receipt. #{@company.name} shall not  entrust #{@current_agency.name}’s Candidate with unattended premises, cash negotiables and other valuables. "
    end
    
    def temporary_agreement
        text "#{@company.name} must utilize #{@current_agency.name}’s Candidate in a temporary capacity for 17 weeks (680 hours) in the position offered. #{@company.name} is responsible for the #{@current_agency.name} hourly rate during said 17 week period (680 hours). #{@current_agency.name}’s Candidate is then released to #{@company.name} at no additional cost. There is no guarantee with a temporary to hire placement."
    end
    def early_release
       text "If #{@company.name} would  like to hire #{@current_agency.name}’s Candidate prior to the completion of 17 weeks (680 hours), #{@company.name} can pay an early release fee based on the number of hours worked and the annual salary offered. Please contact us to discuss the details of the Conversion Schedule. There is no guarantee with a temporary early release."
    end
end