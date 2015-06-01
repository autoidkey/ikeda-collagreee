require "rails_helper"

RSpec.describe FKeywordsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/f_keywords").to route_to("f_keywords#index")
    end

    it "routes to #new" do
      expect(:get => "/f_keywords/new").to route_to("f_keywords#new")
    end

    it "routes to #show" do
      expect(:get => "/f_keywords/1").to route_to("f_keywords#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/f_keywords/1/edit").to route_to("f_keywords#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/f_keywords").to route_to("f_keywords#create")
    end

    it "routes to #update" do
      expect(:put => "/f_keywords/1").to route_to("f_keywords#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/f_keywords/1").to route_to("f_keywords#destroy", :id => "1")
    end

  end
end
