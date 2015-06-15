require 'rails_helper'

RSpec.describe "facilitation_keywords/show", :type => :view do
  before(:each) do
    @facilitation_keyword = assign(:facilitation_keyword, FacilitationKeyword.create!(
      :theme_id => 1,
      :word => "Word",
      :score => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Word/)
    expect(rendered).to match(/1.5/)
  end
end
