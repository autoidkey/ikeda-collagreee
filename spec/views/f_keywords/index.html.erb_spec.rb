require 'rails_helper'

RSpec.describe "f_keywords/index", :type => :view do
  before(:each) do
    assign(:f_keywords, [
      FKeyword.create!(
        :word => "Word",
        :score => 1.5
      ),
      FKeyword.create!(
        :word => "Word",
        :score => 1.5
      )
    ])
  end

  it "renders a list of f_keywords" do
    render
    assert_select "tr>td", :text => "Word".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
