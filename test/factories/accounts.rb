FactoryGirl.define do

  factory :account do
    sequence :site_address do |n|
      "account#{ n }"
    end

    account_plan

    after(:build, :create) do |account, evaluator|
      account.users.new(FactoryGirl.attributes_for(:user))
    end
  end

end