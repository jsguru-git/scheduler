FactoryGirl.define do

  factory :user do
    sequence :firstname do |n|
      "firstname1#{n}"
    end
    sequence :lastname do |n|
      "firstname2#{n}"
    end
    sequence :email do |n|
      "email#{n}@example.com"
    end

    password 'example'
    account

  end

end