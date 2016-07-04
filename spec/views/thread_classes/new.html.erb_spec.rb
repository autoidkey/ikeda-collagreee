require 'rails_helper'

RSpec.describe "thread_classes/new", :type => :view do
  before(:each) do
    assign(:thread_class, ThreadClass.new(
      :title => "MyString",
      :parent_class => "MyString"
    ))
  end

  it "renders new thread_class form" do
    render

    assert_select "form[action=?][method=?]", thread_classes_path, "post" do

      assert_select "input#thread_class_title[name=?]", "thread_class[title]"

      assert_select "input#thread_class_parent_class[name=?]", "thread_class[parent_class]"
    end
  end
end
