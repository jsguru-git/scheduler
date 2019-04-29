FactoryGirl.define do

  factory :account_plan do
    sequence :name do |n|
      "accountplan#{ n }"
    end

    price_in_cents 100

    sequence :chargify_product_handle do |n|
      "example1#{ n }"
    end

    sequence :chargify_product_number do |n|
      n
    end


  end

end