# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :thread_class do
    title "MyString"
    parent_class "MyString"
  end
end
