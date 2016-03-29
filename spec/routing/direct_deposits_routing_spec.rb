# == Schema Information
#
# Table name: direct_deposits
#
#  id                :integer          not null, primary key
#  employee_id       :integer
#  account_number    :string
#  routing_number    :string
#  acct_confirmation :string
#  admin_id          :string
#  effective_date    :datetime
#  account_type      :string           default("Checking")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_direct_deposits_on_employee_id  (employee_id)
#

require "rails_helper"

RSpec.describe DirectDepositsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/direct_deposits").to route_to("direct_deposits#index")
    end

    it "routes to #new" do
      expect(:get => "/direct_deposits/new").to route_to("direct_deposits#new")
    end

    it "routes to #show" do
      expect(:get => "/direct_deposits/1").to route_to("direct_deposits#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/direct_deposits/1/edit").to route_to("direct_deposits#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/direct_deposits").to route_to("direct_deposits#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/direct_deposits/1").to route_to("direct_deposits#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/direct_deposits/1").to route_to("direct_deposits#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/direct_deposits/1").to route_to("direct_deposits#destroy", :id => "1")
    end

  end
end
