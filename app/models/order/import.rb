class Order::Import
    include ActiveModel::Model
    attr_accessor :file, :imported_count, :company_id
    
    
    
    def process!
        @imported_count = 0
        CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
            order = Order.assign_from_row(row, company_id)
            
            if order.save
                @imported_count += 1
            else
                errors.add(:base, "Line #{$.}  - #{order.errors.full_messages.join(",")}")
            end
        end

    end
    
    def save
        process!
        errors.none?
    end
    
end