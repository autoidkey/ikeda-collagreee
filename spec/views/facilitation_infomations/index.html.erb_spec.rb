require 'rails_helper'

RSpec.describe "facilitation_infomations/index", :type => :view do
  before(:each) do
    assign(:facilitation_infomations, [
      FacilitationInfomation.create!(
        :body => "MyText",
        :theme_id => 1
      ),
      FacilitationInfomation.create!(
        :body => "MyText",
        :theme_id => 1
      )
    ])
  end

  it "renders a list of facilitation_infomations" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
