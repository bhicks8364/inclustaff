require 'rails_helper'

RSpec.describe "WorkHistories", type: :request do
  describe "GET /work_histories" do
    it "works! (now write some real specs)" do
      get work_histories_path
      expect(response).to have_http_status(200)
    end
  end
end
