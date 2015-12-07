require 'rails_helper'

RSpec.describe JobsHelper, :type => :helper do
  describe "#user_email" do
    context "when the user exists and has an email" do
      it "returns the user's email" do
        user = double("user", :email => "foo")
        expect(helper.user_email(user)).to eq("foo")
      end
    end

    context "when the user exists and has no email" do
      it "returns nil" do
        user = double("user", :email => nil)
        expect(helper.user_email(user)).to eq(nil)
      end
    end

    context "when the user doesn't exist" do
      it "returns nil" do
        expect(helper.user_email(nil)).to eq(nil)
      end
    end
  end
end