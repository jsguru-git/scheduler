FactoryGirl.define do

  factory :quote do
    
    quote_status 1
    vat_rate 20
    discount_percentage 0.5
    extra_cost_cents 20
    extra_cost_title 'example'

    project
    currency 'gbp'

  end
end