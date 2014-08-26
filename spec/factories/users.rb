FactoryGirl.define do
  factory :user do
    email 'test@test.jp'
    name 'user_name'
    realname 'real_name'
    password 'testtest'
    password_confirmation 'testtest'
    gender 0
    age 10
  end
end
