require 'rails_helper'

RSpec.describe "thread_classes/edit", :type => :view do
  before(:each) do
    @thread_class = assign(:thread_class, ThreadClass.create!(
      :title => "MyString",
      :parent_class => "MyString"
    ))
  end

  it "renders the edit thread_class form" do
    render

    assert_select "form[action=?][method=?]", thread_class_path(@thread_class), "post" do

      assert_select "input#thread_class_title[name=?]", "thread_class[title]"

      assert_select "input#thread_class_parent_class[name=?]", "thread_class[parent_class]"
    end
  end
end
