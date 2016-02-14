# == Schema Information
#
# Table name: shifts
#
#  id             :integer          not null, primary key
#  time_in        :datetime
#  time_out       :datetime
#  employee_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_worked    :decimal(, )
#  job_id         :integer
#  state          :string
#  earnings       :decimal(, )
#  timesheet_id   :integer
#  deleted_at     :datetime
#  in_ip          :string
#  out_ip         :string
#  note           :text
#  needs_adj      :boolean
#  break_duration :decimal(, )
#  paid_breaks    :boolean          default(FALSE)
#  pay_rate       :decimal(, )
#  latitude       :float
#  longitude      :float
#  week           :date
#
# Indexes
#
#  index_shifts_on_deleted_at    (deleted_at)
#  index_shifts_on_job_id        (job_id)
#  index_shifts_on_timesheet_id  (timesheet_id)
#

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
      name = user_signed_in? ? "You" : "#{shift.employee.first_name}"
    
      if shift.on_break?
        "<h3> #{name} #{user_signed_in? ? 'have' : 'has' } been on break for  #{distance_of_time_in_words(shift.breaks.last.time_in, Time.current, include_seconds: true)} </h3>".html_safe
      #TODO: If there are any completed breaks, do this
      elsif shift.breaks.any?
      "<h3>  #{name} took a break for  #{distance_of_time_in_words(shift.breaks.first.time_in, shift.breaks.last.try(:time_out) || Time.current , include_seconds: true)} </h3>".html_safe
        
      elsif !shift.took_a_break? && shift.today?
      "<h3>  #{name} did not take a break. </h3>".html_safe
      end
    end
    def break_times_for(shift)
      @str = ""
      shift.breaks.each do |shift_break|
        @str += "Start: #{shift_break.time_in.stamp("1:30am")} <br />"
        @str += "End: #{shift_break.time_out.stamp("1:30am")} <br />" if shift_break.time_out?
      end
      @str.html_safe
    end
    # "Total Break Time:  #{shift.break_duration}
    # Total Actual Time:  #{shift.time_worked}
    # Total (w/ paid breaks):  #{number_to_currency(shift.with_paid_breaks)}
    # Total (w/ unpaid break):  #{number_to_currency(shift.with_unpaid_breaks) }"
    def shift_popover(shift)
        "<i class='fa fa-info-circle' data-placement='top' data-toggle='popover' title='#{ shift.id}'
        data-content='#{ shift.state }'></i>".html_safe
    end

    def shift_sym(shift)
      if shift.on_break?
        "<i class='fa fa-spinner fa-spin' data-toggle='tooltip' data-placement='top' title='On Break'></i>".html_safe
      elsif shift.clocked_in?
        "<i class='fa fa-cog fa-spin'></i data-toggle='tooltip' data-placement='top' title='Clocked In'></i>".html_safe
      else
        "<i class='fa fa-cog'></i data-toggle='tooltip' data-placement='top' title='Clocked Out'></i>".html_safe
      end
    end
    def breaks_collaspe(shift)
      "<a class='btn btn-primary' role='button' data-toggle='collapse' href='#collapseShiftBreaks_#{shift.id}' aria-expanded='false' aria-controls='collapseShiftBreaks_#{shift.id}'>
        <i class='fa fa-history fa-fw'></i> <small>Break Details</small>
      </a>".html_safe
    end
    def comments_collaspe(shift)
      "<a class='btn btn-primary' role='button' data-toggle='collapse' href='#collapseShiftComments_#{shift.id}' aria-expanded='false' aria-controls='collapseShiftComments_#{shift.id}'>
       <i class='fa fa-commenting fa-fw'></i> <small>Comments</small>
      </a>".html_safe
    end
    def shift_collaspe(shift)
      title = user_signed_in? ? "#{number_to_currency(shift.earnings)}" : "#{shift.employee.name}"
      "<a class='button' role='button' data-toggle='collapse' href='#collapseShift_#{shift.id}' aria-expanded='false' aria-controls='collapseShift_#{shift.id}'>
        #{shift_sym(shift)} <small>#{truncate(title)}</small>
      </a>".html_safe
    end













end
