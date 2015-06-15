require 'rails_helper'

RSpec.describe "facilitation_keywords/edit", :type => :view do
  before(:each) do
    @facilitation_keyword = assign(:facilitation_keyword, FacilitationKeyword.create!(
      :theme_id => 1,
      :word => "MyString",
      :score => 1.5
    ))
  end

  it "renders the edit facilitation_keyword form" do
    render

    assert_select "form[action=?][method=?]", facilitation_keyword_path(@facilitation_keyword), "post" do

      assert_select "input#facilitation_keyword_theme_id[name=?]", "facilitation_keyword[theme_id]"

      assert_select "input#facilitation_keyword_word[name=?]", "facilitation_keyword[word]"

      assert_select "input#facilitation_keyword_score[name=?]", "facilitation_keyword[score]"
    end
  end
end
