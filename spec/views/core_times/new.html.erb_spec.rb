require 'rails_helper'

RSpec.describe "core_times/new", :type => :view do
  before(:each) do
    assign(:core_time, CoreTime.new(
      :theme_id => 1,
      :notice => false
    ))
  end

  it "renders new core_time form" do
    render

    assert_select "form[action=?][method=?]", core_times_path, "post" do

      assert_select "input#core_time_theme_id[name=?]", "core_time[theme_id]"

      assert_select "input#core_time_notice[name=?]", "core_time[notice]"
    end
  end
end
