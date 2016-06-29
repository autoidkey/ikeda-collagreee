require "rails_helper"

RSpec.describe ThreadClassesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/thread_classes").to route_to("thread_classes#index")
    end

    it "routes to #new" do
      expect(:get => "/thread_classes/new").to route_to("thread_classes#new")
    end

    it "routes to #show" do
      expect(:get => "/thread_classes/1").to route_to("thread_classes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/thread_classes/1/edit").to route_to("thread_classes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/thread_classes").to route_to("thread_classes#create")
    end

    it "routes to #update" do
      expect(:put => "/thread_classes/1").to route_to("thread_classes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/thread_classes/1").to route_to("thread_classes#destroy", :id => "1")
    end

  end
end
