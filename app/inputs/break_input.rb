class BreakInput < SimpleForm::Inputs::Base
  def input(wrapper_options, breaks=[])
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    
    breaks.map do |b|
      @builder.datetime_field(nil, input_html_options.merge(value: b.to_datetime, name: "#{shift}[#{breaks}][]"))
    end.join.html_safe
    
  end
  
  
  
end