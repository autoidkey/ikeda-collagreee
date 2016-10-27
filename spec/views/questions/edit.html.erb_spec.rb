require 'rails_helper'

RSpec.describe "questions/edit", :type => :view do
  before(:each) do
    @question = assign(:question, Question.create!(
      :live => "MyString",
      :city_name_1 => "MyString",
      :city_reason_1 => "MyText",
      :city_name_2 => "MyString",
      :city_reason_2 => "MyText",
      :city_name_3 => "MyString",
      :city_reason_3 => "MyText",
      :city_name_4 => "MyString",
      :city_reason_4 => "MyText",
      :city_name_5 => "MyString",
      :city_reason_5 => "MyText",
      :city_name_6 => "MyString",
      :city_reason_6 => "MyText",
      :q1 => "MyText",
      :q2 => "MyText",
      :q3_1 => "MyString",
      :q3_2 => "MyText"
    ))
  end

  it "renders the edit question form" do
    render

    assert_select "form[action=?][method=?]", question_path(@question), "post" do

      assert_select "input#question_live[name=?]", "question[live]"

      assert_select "input#question_city_name_1[name=?]", "question[city_name_1]"

      assert_select "textarea#question_city_reason_1[name=?]", "question[city_reason_1]"

      assert_select "input#question_city_name_2[name=?]", "question[city_name_2]"

      assert_select "textarea#question_city_reason_2[name=?]", "question[city_reason_2]"

      assert_select "input#question_city_name_3[name=?]", "question[city_name_3]"

      assert_select "textarea#question_city_reason_3[name=?]", "question[city_reason_3]"

      assert_select "input#question_city_name_4[name=?]", "question[city_name_4]"

      assert_select "textarea#question_city_reason_4[name=?]", "question[city_reason_4]"

      assert_select "input#question_city_name_5[name=?]", "question[city_name_5]"

      assert_select "textarea#question_city_reason_5[name=?]", "question[city_reason_5]"

      assert_select "input#question_city_name_6[name=?]", "question[city_name_6]"

      assert_select "textarea#question_city_reason_6[name=?]", "question[city_reason_6]"

      assert_select "textarea#question_q1[name=?]", "question[q1]"

      assert_select "textarea#question_q2[name=?]", "question[q2]"

      assert_select "input#question_q3_1[name=?]", "question[q3_1]"

      assert_select "textarea#question_q3_2[name=?]", "question[q3_2]"
    end
  end
end
