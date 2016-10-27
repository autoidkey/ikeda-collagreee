require 'rails_helper'

RSpec.describe "questions/show", :type => :view do
  before(:each) do
    @question = assign(:question, Question.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Live/)
    expect(rendered).to match(/City Name 1/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/City Name 2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/City Name 3/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/City Name 4/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/City Name 5/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/City Name 6/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Q3 1/)
    expect(rendered).to match(/MyText/)
  end
end
