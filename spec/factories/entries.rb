FactoryGirl.define do
  factory :entry do
    title 'title'
    body 'body'
    np 1
    user_id 0                   # 取り敢えず
    theme_id 0
  end
end
