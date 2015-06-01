require 'rails_helper'

RSpec.describe "facilitation_keywords/new", :type => :view do
  before(:each) do
    assign(:facilitation_keyword, FacilitationKeyword.new(
      :theme_id => 1,
      :word => "MyString",
      :score => 1.5
    ))
  end

  it "renders new facilitation_keyword form" do
    render

    assert_select "form[action=?][method=?]", facilitation_keywords_path, "post" do

      assert_select "input#facilitation_keyword_theme_id[name=?]", "facilitation_keyword[theme_id]"

      assert_select "input#facilitation_keyword_word[name=?]", "facilitation_keyword[word]"

      assert_select "input#facilitation_keyword_score[name=?]", "facilitation_keyword[score]"
    end
  end
end
