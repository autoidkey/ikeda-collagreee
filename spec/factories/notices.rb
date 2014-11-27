# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notice do
    ntype 1
    user_id 1
    read false
    point_history_id 1
  end
end
