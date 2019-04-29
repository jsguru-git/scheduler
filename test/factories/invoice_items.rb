FactoryGirl.define do

  factory :invoice_item do
    sequence :name do |n|
      "Item#{n}"
    end
  end

end