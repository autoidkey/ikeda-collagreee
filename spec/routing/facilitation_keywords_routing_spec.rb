require "rails_helper"

RSpec.describe FacilitationKeywordsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/facilitation_keywords").to route_to("facilitation_keywords#index")
    end

    it "routes to #new" do
      expect(:get => "/facilitation_keywords/new").to route_to("facilitation_keywords#new")
    end

    it "routes to #show" do
      expect(:get => "/facilitation_keywords/1").to route_to("facilitation_keywords#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/facilitation_keywords/1/edit").to route_to("facilitation_keywords#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/facilitation_keywords").to route_to("facilitation_keywords#create")
    end

    it "routes to #update" do
      expect(:put => "/facilitation_keywords/1").to route_to("facilitation_keywords#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/facilitation_keywords/1").to route_to("facilitation_keywords#destroy", :id => "1")
    end

  end
end
