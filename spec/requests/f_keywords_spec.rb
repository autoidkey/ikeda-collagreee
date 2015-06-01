require 'rails_helper'

RSpec.describe "FKeywords", :type => :request do
  describe "GET /f_keywords" do
    it "works! (now write some real specs)" do
      get f_keywords_path
      expect(response.status).to be(200)
    end
  end
end
