require "rails_helper"

RSpec.describe CoreTimesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/core_times").to route_to("core_times#index")
    end

    it "routes to #new" do
      expect(:get => "/core_times/new").to route_to("core_times#new")
    end

    it "routes to #show" do
      expect(:get => "/core_times/1").to route_to("core_times#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/core_times/1/edit").to route_to("core_times#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/core_times").to route_to("core_times#create")
    end

    it "routes to #update" do
      expect(:put => "/core_times/1").to route_to("core_times#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/core_times/1").to route_to("core_times#destroy", :id => "1")
    end

  end
end
