module ShiftsHelper
  
  def  shift_times_in_words(shift)
    if shift.clocked_out?
      distance_of_time_in_words(shift.time_in, shift.time_out, include_seconds: true)
    else
      distance_of_time_in_words(shift.time_in, Time.current, include_seconds: true)
    end
  end 
  
  def  shift_times(shift)
    if shift.clocked_out?
      "#{shift.time_in.stamp("1:30am")} - #{shift.time_out.stamp("1:30am")}"
    else
      "#{shift.time_in.stamp("1:30am")} - #{shift.state}"
    end
  end 
  
  
  
    def on_break_for(shift)
      
      if shift.on_break? 
      "<h3>  #{shift.employee.first_name}  has been on break for  #{distance_of_time_in_words(shift.breaks.last, Time.current, include_seconds: true)} </h3>".html_safe
      elsif shift.breaks.count >= 2
      "<h4>  #{shift.employee.first_name}  took a break for   #{distance_of_time_in_words(shift.breaks[0], shift.breaks[1]) } </h4>".html_safe
      elsif !shift.took_a_break?
      "<h4>  #{shift.employee.first_name}  has not taken a break. </h4>".html_safe
      end
    end
    def break_times_for(shift)
    "Total Break Time:  #{shift.break_duration}
    Total Actual Time:  #{shift.time_worked} 
    Total (w/ paid breaks):  #{number_to_currency(shift.with_paid_breaks)} 
    Total (w/ unpaid break):  #{number_to_currency(shift.with_unpaid_breaks) }"
    end

  
  
  
  
  
  
  
  
  
  
  
  
end
