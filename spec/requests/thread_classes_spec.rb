require 'rails_helper'

RSpec.describe "ThreadClasses", :type => :request do
  describe "GET /thread_classes" do
    it "works! (now write some real specs)" do
      get thread_classes_path
      expect(response.status).to be(200)
    end
  end
end
