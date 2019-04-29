FactoryGirl.define do

  factory :role do

    trait :account_holder do
      title 'account_holder'
    end

    trait :administrator do
      title 'administrator'
    end

    trait :leader do
      title 'leader'
    end

    trait :member do
      title 'member'
    end

  end

end