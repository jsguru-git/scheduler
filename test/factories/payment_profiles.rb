FactoryGirl.define do

  factory :payment_profile do

    project

    name 'example payment profile'
    expected_payment_date { 5.days.from_now }

    expected_cost_cents 1000
    expected_cost 100

    expected_minutes 100
    expected_days 1.52

  end

end