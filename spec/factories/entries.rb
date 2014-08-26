FactoryGirl.define do
  factory :entry do
    title 'title'
    body 'body'
    np 1

    # after(:user_id) do |ui|
    #   ui = FactoryGirl.create(:user).id
    # end
  end
end
