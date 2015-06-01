require 'rails_helper'

RSpec.describe "f_keywords/edit", :type => :view do
  before(:each) do
    @f_keyword = assign(:f_keyword, FKeyword.create!(
      :word => "MyString",
      :score => 1.5
    ))
  end

  it "renders the edit f_keyword form" do
    render

    assert_select "form[action=?][method=?]", f_keyword_path(@f_keyword), "post" do

      assert_select "input#f_keyword_word[name=?]", "f_keyword[word]"

      assert_select "input#f_keyword_score[name=?]", "f_keyword[score]"
    end
  end
end
