require 'rails_helper'

RSpec.describe "f_keywords/show", :type => :view do
  before(:each) do
    @f_keyword = assign(:f_keyword, FKeyword.create!(
      :word => "Word",
      :score => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Word/)
    expect(rendered).to match(/1.5/)
  end
end
