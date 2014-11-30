# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :point_history do
    user_id 1
    entry_id 1
    theme_id 1
    activity_id 1
    point 1.5
    atype 1
    action 1
    depth 1

    association :user, factory: :user
    association :theme, factory: :theme

  end
end
