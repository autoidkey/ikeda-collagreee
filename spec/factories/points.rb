# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :point do
    theme_id 1
    user_id 1
    latest false
    entry 1
    reply 1
    like 1
    replied 1
    liked 1
  end
end
