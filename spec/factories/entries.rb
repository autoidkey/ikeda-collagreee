FactoryGirl.define do
  factory :entry do
    title 'entry_title'
    body 'entry_body'
    np 50

    association :user, factory: :user
    association :theme, factory: :theme
  end
end
