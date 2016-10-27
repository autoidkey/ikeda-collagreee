# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    live "MyString"
    city_name_1 "MyString"
    city_reason_1 "MyText"
    city_name_2 "MyString"
    city_reason_2 "MyText"
    city_name_3 "MyString"
    city_reason_3 "MyText"
    city_name_4 "MyString"
    city_reason_4 "MyText"
    city_name_5 "MyString"
    city_reason_5 "MyText"
    city_name_6 "MyString"
    city_reason_6 "MyText"
    q1 "MyText"
    q2 "MyText"
    q3_1 "MyString"
    q3_2 "MyText"
  end
end
