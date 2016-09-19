require 'rails_helper'

RSpec.describe "core_times/show", :type => :view do
  before(:each) do
    @core_time = assign(:core_time, CoreTime.create!(
      :theme_id => 1,
      :notice => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/false/)
  end
end
