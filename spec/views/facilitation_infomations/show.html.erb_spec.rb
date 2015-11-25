require 'rails_helper'

RSpec.describe "facilitation_infomations/show", :type => :view do
  before(:each) do
    @facilitation_infomation = assign(:facilitation_infomation, FacilitationInfomation.create!(
      :body => "MyText",
      :theme_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
  end
end
