# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :core_time do
    theme_id 1
    start_at "2016-09-19 11:45:44"
    end_at "2016-09-19 11:45:44"
    notice false
  end
end
