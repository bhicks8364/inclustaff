class EmployeeAcaPdf < Prawn::Document
    attr_reader :attributes, :id, :name, :email, :position, :name, :initial_start_date, :line_items
    
    def initialize(attributes)
        @attributes  = attributes
        @id          = attributes.fetch(:id)
        @name = attributes.fetch(:name)
        @line_items  = attributes.fetch(:line_items)
        @custom_font = attributes.fetch(:font, {})
        default_message
        super(margin: 0)
        
        generate
    end
    
    private
    
    def default_message
        "ACA Report for #{name}"
    end
    
    def setup_fonts
        font_families.update "Primary" => custom_font
        font "Primary"
    end
    
    def generate
        bounding_box [0, 792], width: 612, height: 792 do
          bounding_box [85, 792], width: 442, height: 792 do
            header
            footer
          end
        end
    end
    
        

    
    
    def header
        company = {}
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
        text default_message, inline_format: true, size: 12.5, leading: 4
    end
    
   
    def footer
        move_down 45
        text "<color rgb='888888'>Footer</color>", inline_format: true
    end
end