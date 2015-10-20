require 'rails_helper'

RSpec.describe "FacilitationInfomations", :type => :request do
  describe "GET /facilitation_infomations" do
    it "works! (now write some real specs)" do
      get facilitation_infomations_path
      expect(response.status).to be(200)
    end
  end
end
