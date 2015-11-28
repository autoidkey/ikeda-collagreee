# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :treedatum, :class => 'Treedata' do
    user_id 1
    theme_id 1
  end
end
