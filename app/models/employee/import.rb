class Employee::Import
    include ActiveModel::Model
    attr_accessor :file, :imported_count
    
    
    
    def process!
        @imported_count = 0
        CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
            employee = Employee.assign_from_row(row)
            if employee.save
                @imported_count += 1
            else
                errors.add(:base, "Line #{$.}  - #{employee.errors.full_messages.join(",")}")
            end
        end

    end
    
    def save
        process!
        errors.none?
    end
    
end