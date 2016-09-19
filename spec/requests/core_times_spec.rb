require 'rails_helper'

RSpec.describe "CoreTimes", :type => :request do
  describe "GET /core_times" do
    it "works! (now write some real specs)" do
      get core_times_path
      expect(response.status).to be(200)
    end
  end
end
