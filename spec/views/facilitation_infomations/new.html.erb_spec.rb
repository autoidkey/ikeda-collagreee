require 'rails_helper'

RSpec.describe "facilitation_infomations/new", :type => :view do
  before(:each) do
    assign(:facilitation_infomation, FacilitationInfomation.new(
      :body => "MyText",
      :theme_id => 1
    ))
  end

  it "renders new facilitation_infomation form" do
    render

    assert_select "form[action=?][method=?]", facilitation_infomations_path, "post" do

      assert_select "textarea#facilitation_infomation_body[name=?]", "facilitation_infomation[body]"

      assert_select "input#facilitation_infomation_theme_id[name=?]", "facilitation_infomation[theme_id]"
    end
  end
end
