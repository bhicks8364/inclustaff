class CandidatePdf < Prawn::Document
    attr_reader :attributes, :id, :company, :recruiter_name, :recruiter_email, :position_name, :candidate_name, :company_name, :custom_font, :line_items, :logo, :message, :product
    
    def initialize(attributes)
        @attributes  = attributes
        @id          = attributes.fetch(:id)
        @company= attributes.fetch(:company)
        @company_name = attributes.fetch(:company_name)
        @recruiter_name          = attributes.fetch(:recruiter_name)
        @recruiter_email     = attributes.fetch(:recruiter_email)
        @candidate_name          = attributes.fetch(:candidate_name)
        @position_name     = attributes.fetch(:position_name)
        @line_items  = attributes.fetch(:line_items)
        @custom_font = attributes.fetch(:font, {})
        
        super(margin: 0)
        
        setup_fonts if custom_font.any?
        generate
    end
    
    private
    
    def default_message
        "#{recruiter_name} is presenting #{candidate_name} for a #{position_name} at #{company_name}."
    end
    
    def setup_fonts
        font_families.update "Primary" => custom_font
        font "Primary"
    end
    
    def generate
        bounding_box [0, 792], width: 612, height: 792 do
          bounding_box [85, 792], width: 442, height: 792 do
            header
            charge_details
            footer
          end
        end
    end
    
    def header
        move_down 60
        text default_message
        if company.has_key? :logo
          image open(company.fetch(:logo)), height: 50, align: :center
        else
          move_down 32
        end
        
        move_down 8
        text "<color rgb='a6a6a6'> ##{id}</color>", inline_format: true
        
        move_down 30
        text message, inline_format: true, size: 12.5, leading: 4
    end
    
    def charge_details
        move_down 30
        
        borders = line_items.length - 2
        
        table(line_items, cell_style: { border_color: 'cccccc' }) do
          cells.padding = 12
          cells.borders = []
          row(0..borders).borders = [:bottom]
        end
    end
    
    def footer
        move_down 45
        text company.fetch(:name), inline_format: true
        text "<color rgb='888888'>#{company.fetch(:address)}</color>", inline_format: true
    end
end