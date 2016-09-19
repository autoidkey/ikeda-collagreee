require 'rails_helper'

RSpec.describe "core_times/index", :type => :view do
  before(:each) do
    assign(:core_times, [
      CoreTime.create!(
        :theme_id => 1,
        :notice => false
      ),
      CoreTime.create!(
        :theme_id => 1,
        :notice => false
      )
    ])
  end

  it "renders a list of core_times" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
