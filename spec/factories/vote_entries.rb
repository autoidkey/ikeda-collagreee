# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vote_entry do
    user_id 1
    entry_id 1
    point 1
  end
end
