class DashboardPolicy < Struct.new(:user, :dashboard)
    def home?
        false
    end

end