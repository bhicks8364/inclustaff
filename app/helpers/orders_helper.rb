# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  notes                     :text
#  number_needed             :integer
#  needed_by                 :datetime
#  urgent                    :boolean
#  active                    :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  title                     :string
#  deleted_at                :datetime
#  manager_id                :integer
#  jobs_count                :integer
#  account_manager_id        :integer
#  mark_up                   :decimal(, )
#  agency_id                 :integer
#  dt_req                    :string
#  bg_check                  :string
#  heavy_lifting             :boolean
#  stwb                      :boolean
#  est_duration              :string
#  shift                     :string
#  bwc_code                  :string
#  min_pay                   :decimal(, )
#  max_pay                   :decimal(, )
#  pay_frequency             :string
#  address                   :string
#  latitude                  :float
#  longitude                 :float
#  aca_type                  :string
#  education                 :hstore           default({})
#  requirements              :hstore           default({})
#  industry                  :string
#  published_at              :datetime
#  published_by              :integer
#  expires_at                :datetime
#  mobile_time_clock_enabled :boolean          default(FALSE)
#
# Indexes
#
#  index_orders_on_account_manager_id  (account_manager_id)
#  index_orders_on_agency_id           (agency_id)
#  index_orders_on_deleted_at          (deleted_at)
#  index_orders_on_industry            (industry)
#  index_orders_on_manager_id          (manager_id)
#  index_orders_on_published_by        (published_by)
#

module OrdersHelper
    include ActsAsTaggableOn::TagsHelper
    
    def order_skills_popover(order)
        "<span class='black'><i class='fa fa-wrench fa-lg' data-placement='right' data-toggle='popover' title='Skills for #{ order.title}' 
        data-content='#{ order.skills.any? ? order.skills.map {|p| p.name.titleize}.join(', ') : order.tag_list }'></i></span>".html_safe
    end
    def status_msg(order)
        @str = ""
        if order.overdue? 
            @str += "Overdue " + "  #{order.needed_by.stamp("11/12/2015")}"
        elsif order.priority?
            @str += "Priority " + "    #{order.needed_by.stamp("11/12/2015")}"
        elsif order.needs_attention? && order.needed_by.present?
            @str += "Open " + "  #{order.needed_by.stamp("11/12/2015")}"
        elsif order.filled?
            @str += "Filled in " + "#{distance_of_time_in_words(order.created_at, order.jobs.last.try(:created_at), include_seconds: true)}"
        elsif order.has_pending_jobs?
            @str += "<p class='green'><strong>Open</strong></p> " + " #{pluralize(order.jobs.pending_approval.count, 'placement')} pending" + "  #{order.needed_by.stamp("11/12/2015")}"
        end
        @str.html_safe
    end
    
    def order_status(order)
        if order.overdue?
            "<span class='red'>Overdue</span>".html_safe
        elsif order.priority?
            "<span class='red'>Priority</span>".html_safe
        elsif order.needs_attention?
            "<span class='green'>Open</span>".html_safe
        elsif order.filled?
            "<span class='bold'>Filled</span>".html_safe
        elsif order.inactive?
            "<span class='red'>Inactive</span>".html_safe
        else
            ""
        end
    end
    
    def info_popover(order)
        "<span class='black'><i class='fa fa-user' data-placement='top' data-toggle='popover' title='#{ order.title_company}' 
        data-content='Account Manager: #{ order.account_manager.present? ? order.account_manager.name : "Unavailable"}'></i></span>".html_safe
    end
    def matching_emp_popover(order)
        "<span class='black rainbow'><i class='fa fa-users' data-toggle='popover' data-placement='top' title='#{ order.matching_employees.count} Matching Candidates' 
        data-content='#{ order.matching_employees.map {|p| p.name.titleize}.join(', ')}'></i></span>".html_safe
    end
   
    def lg_status_tag(order)
        if order.overdue?
            "<i class='fa fa-exclamation fa-3x fa-border red' data-toggle='tooltip' data-placement='right' title='#{pluralize(order.open_jobs, "open job")}'></i>".html_safe
        elsif order.priority?
        "<i class='fa fa-exclamation-circle fa-3x fa-border red' data-toggle='tooltip' data-placement='right' title='#{pluralize(order.open_jobs, "open job")}'></i>".html_safe
        elsif order.needs_attention?
            "<i class='fa fa-clock-o fa-3x fa-border' data-toggle='tooltip' data-placement='right' title='#{pluralize(order.open_jobs, "open job")}'></i>".html_safe
        elsif order.filled?
        "<i class='fa fa-check-circle fa-3x fa-border green' data-toggle='tooltip' data-placement='right' title='#{pluralize(order.open_jobs, "open job")}'></i>".html_safe
        end
    end
    def status_tag(order, options={})
        options[:class] ? options[:class] += ' status_msg' : options[:class] = 'status_msg'
        if order.overdue?
            "<i class='fa fa-exclamation fa-fw red' data-toggle='tooltip' data-placement='right' title='#{status_msg(order)}'></i>".html_safe
        elsif order.priority?
            "<i class='fa fa-exclamation-circle fa-fw red' data-toggle='tooltip' data-placement='right' title='#{status_msg(order)}'></i>".html_safe
        elsif order.needs_attention?
            "<i class='fa fa-clock-o fa-fw' data-toggle='tooltip' data-placement='right' title='#{status_msg(order)}'></i>".html_safe
        elsif order.filled?
            "<i class='fa fa-check fa-fw green' data-toggle='tooltip' data-placement='right' title='#{status_msg(order)}'></i>".html_safe
        elsif order.inactive?
            "<i class='fa fa-history fa-fw red' data-toggle='tooltip' data-placement='right' title='Inactive'></i>".html_safe
        end
    end
    def title_for(order)
        "<span class='black' data-placement='right' data-toggle='tooltip' title=' #{ order.company.name}'>#{order.title }</span>".html_safe
    end
    def heavy_lifting(order)
        if order.heavy_lifting?
            "<i class='fa fa-anchor fa-fw' data-toggle='tooltip' data-placement='right' title='Heavy lifting required'></i>".html_safe
        end
    end
    def stwb(order)
        if order.stwb?
            "<i class='fa fa-certificate fa-fw' data-toggle='tooltip' data-placement='right' title='Steel Toe Workboots required'></i>".html_safe
        end
    end
    def title_count(order)
        "<span class=''><strong>#{order.title}</strong></span> (#{number_to_currency(order.min_pay)} - #{number_to_currency(order.max_pay)}) #{pluralize(order.open_jobs, "open jobs")}".html_safe
    end
    def pay_range(order)
        if order.min_pay == order.max_pay
            number_to_currency(order.min_pay)
        else
            "#{number_to_currency(order.min_pay)} - #{number_to_currency(order.max_pay)}"
        end
    end
    def order_count(order)
        "<span class='' data-toggle='tooltip' data-placement='right' title='#{order.jobs.active.count}/#{order.number_needed}'>#{order.open_jobs}</span>".html_safe
    end
end
