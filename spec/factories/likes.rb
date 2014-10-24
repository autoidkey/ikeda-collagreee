FactoryGirl.define do
  factory :like do
    entry_id 1
    user_id 1
    theme_id 1
    activity_id 1

    association :user, factory: :user
    association :entry, factory: :entry
    association :theme, factory: :theme

  end
end
