require 'rails_helper'

RSpec.describe "f_keywords/new", :type => :view do
  before(:each) do
    assign(:f_keyword, FKeyword.new(
      :word => "MyString",
      :score => 1.5
    ))
  end

  it "renders new f_keyword form" do
    render

    assert_select "form[action=?][method=?]", f_keywords_path, "post" do

      assert_select "input#f_keyword_word[name=?]", "f_keyword[word]"

      assert_select "input#f_keyword_score[name=?]", "f_keyword[score]"
    end
  end
end
