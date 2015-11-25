require 'rails_helper'

RSpec.describe "facilitation_infomations/edit", :type => :view do
  before(:each) do
    @facilitation_infomation = assign(:facilitation_infomation, FacilitationInfomation.create!(
      :body => "MyText",
      :theme_id => 1
    ))
  end

  it "renders the edit facilitation_infomation form" do
    render

    assert_select "form[action=?][method=?]", facilitation_infomation_path(@facilitation_infomation), "post" do

      assert_select "textarea#facilitation_infomation_body[name=?]", "facilitation_infomation[body]"

      assert_select "input#facilitation_infomation_theme_id[name=?]", "facilitation_infomation[theme_id]"
    end
  end
end
