FactoryGirl.define do
  factory :issue do
    name 'tag_name'
    association :theme, factory: :theme
  end
end
