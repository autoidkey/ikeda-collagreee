require 'rails_helper'

RSpec.describe "thread_classes/show", :type => :view do
  before(:each) do
    @thread_class = assign(:thread_class, ThreadClass.create!(
      :title => "Title",
      :parent_class => "Parent Class"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Parent Class/)
  end
end
