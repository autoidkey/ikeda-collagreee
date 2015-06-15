require 'rails_helper'

RSpec.describe "facilitation_keywords/index", :type => :view do
  before(:each) do
    assign(:facilitation_keywords, [
      FacilitationKeyword.create!(
        :theme_id => 1,
        :word => "Word",
        :score => 1.5
      ),
      FacilitationKeyword.create!(
        :theme_id => 1,
        :word => "Word",
        :score => 1.5
      )
    ])
  end

  it "renders a list of facilitation_keywords" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Word".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
