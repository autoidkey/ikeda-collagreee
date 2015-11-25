require "rails_helper"

RSpec.describe FacilitationInfomationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/facilitation_infomations").to route_to("facilitation_infomations#index")
    end

    it "routes to #new" do
      expect(:get => "/facilitation_infomations/new").to route_to("facilitation_infomations#new")
    end

    it "routes to #show" do
      expect(:get => "/facilitation_infomations/1").to route_to("facilitation_infomations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/facilitation_infomations/1/edit").to route_to("facilitation_infomations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/facilitation_infomations").to route_to("facilitation_infomations#create")
    end

    it "routes to #update" do
      expect(:put => "/facilitation_infomations/1").to route_to("facilitation_infomations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/facilitation_infomations/1").to route_to("facilitation_infomations#destroy", :id => "1")
    end

  end
end
