module ControllerHelpers
    def sign_in(user = double('user'))
      if user.nil?
        allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, {:scope => :user})
        allow(controller).to receive(:current_user).and_return(nil)
      else
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end
    end
    
    def sign_in(admin = double('admin'))
      if admin.nil?
        allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, {:scope => :admin})
        allow(controller).to receive(:current_admin).and_return(nil)
      else
        allow(request.env['warden']).to receive(:authenticate!).and_return(admin)
        allow(controller).to receive(:current_admin).and_return(admin)
      end
    end
    
end

RSpec.configure do |config|
    config.include Devise::TestHelpers, :type => :controller
    config.include ControllerHelpers, :type => :controller
end