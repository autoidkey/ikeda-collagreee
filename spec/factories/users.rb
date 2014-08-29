FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    sequence(:name) { |n| "user_name#{n}" }
    realname 'real_name'
    password 'testtest'
    password_confirmation 'testtest'
    gender 0
    age 10
    role 2

    factory :admin do
      role 0
    end

    factory :facilitator do
      role 1
    end
  end

end
