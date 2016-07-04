require 'rails_helper'

RSpec.describe "thread_classes/index", :type => :view do
  before(:each) do
    assign(:thread_classes, [
      ThreadClass.create!(
        :title => "Title",
        :parent_class => "Parent Class"
      ),
      ThreadClass.create!(
        :title => "Title",
        :parent_class => "Parent Class"
      )
    ])
  end

  it "renders a list of thread_classes" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Parent Class".to_s, :count => 2
  end
end
