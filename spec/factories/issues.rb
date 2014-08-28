FactoryGirl.define do
  factory :issue do
    association :theme, factory: :theme
    name 'tag_name'
  end
end
