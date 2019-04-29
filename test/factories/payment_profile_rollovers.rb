FactoryGirl.define do

  factory :payment_profile_rollover do

    account
    project
    payment_profile
    user

    old_expected_payment_date { 3.days.ago }
    new_expected_payment_date { 3.days.from_now }
    reason_for_date_change 'example reason'

  end

end