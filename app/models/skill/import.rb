class Skill::Import
    include ActiveModel::Model
    attr_accessor :file, :imported_count
    
    
    
    def process!
        @imported_count = 0
        CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
            skill = Skill.assign_from_row(row)
            
            if skill.save
                @imported_count += 1
            else
                errors.add(:base, "Line #{$.}  - #{skill.errors.full_messages.join(",")}")
            end
        end

    end
    
    def save
        process!
        errors.none?
    end
    
end