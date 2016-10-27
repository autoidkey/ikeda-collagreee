require 'rails_helper'

RSpec.describe "questions/index", :type => :view do
  before(:each) do
    assign(:questions, [
      Question.create!(
        :live => "Live",
        :city_name_1 => "City Name 1",
        :city_reason_1 => "MyText",
        :city_name_2 => "City Name 2",
        :city_reason_2 => "MyText",
        :city_name_3 => "City Name 3",
        :city_reason_3 => "MyText",
        :city_name_4 => "City Name 4",
        :city_reason_4 => "MyText",
        :city_name_5 => "City Name 5",
        :city_reason_5 => "MyText",
        :city_name_6 => "City Name 6",
        :city_reason_6 => "MyText",
        :q1 => "MyText",
        :q2 => "MyText",
        :q3_1 => "Q3 1",
        :q3_2 => "MyText"
      ),
      Question.create!(
        :live => "Live",
        :city_name_1 => "City Name 1",
        :city_reason_1 => "MyText",
        :city_name_2 => "City Name 2",
        :city_reason_2 => "MyText",
        :city_name_3 => "City Name 3",
        :city_reason_3 => "MyText",
        :city_name_4 => "City Name 4",
        :city_reason_4 => "MyText",
        :city_name_5 => "City Name 5",
        :city_reason_5 => "MyText",
        :city_name_6 => "City Name 6",
        :city_reason_6 => "MyText",
        :q1 => "MyText",
        :q2 => "MyText",
        :q3_1 => "Q3 1",
        :q3_2 => "MyText"
      )
    ])
  end

  it "renders a list of questions" do
    render
    assert_select "tr>td", :text => "Live".to_s, :count => 2
    assert_select "tr>td", :text => "City Name 1".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "City Name 2".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "City Name 3".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "City Name 4".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "City Name 5".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "City Name 6".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Q3 1".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
