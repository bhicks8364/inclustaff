module ApplicationHelper
    def format_time(time)
        time.blank? ? "&nbsp;" : time.stamp("8:45am")
    end
    def short_date(date)
        date.blank? ? "&nbsp;" : date.stamp("6/2")
    end
    def full_date(date)
        date.blank? ? "&nbsp;" : date.stamp("6/2/2015")
    end
    def date_and_time(datetime)
        datetime.blank? ? "&nbsp;" : datetime.stamp("6/2 8:45am")
    end
end
