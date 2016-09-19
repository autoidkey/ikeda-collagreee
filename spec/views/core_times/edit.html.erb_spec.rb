require 'rails_helper'

RSpec.describe "core_times/edit", :type => :view do
  before(:each) do
    @core_time = assign(:core_time, CoreTime.create!(
      :theme_id => 1,
      :notice => false
    ))
  end

  it "renders the edit core_time form" do
    render

    assert_select "form[action=?][method=?]", core_time_path(@core_time), "post" do

      assert_select "input#core_time_theme_id[name=?]", "core_time[theme_id]"

      assert_select "input#core_time_notice[name=?]", "core_time[notice]"
    end
  end
end
