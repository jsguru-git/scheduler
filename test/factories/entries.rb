FactoryGirl.define do

  factory :entry do
    start_date { Date.today }
    end_date  { 1.week.from_now }
    project
    account
    user

    trait :future do
      start_date { 1.day.from_now }
      end_date { 8.days.from_now }
    end

    trait :present do
      start_date { 2.days.ago }
      end_date { 3.days.from_now }
    end

    trait :past do
      start_date { 6.days.ago }
      end_date { 1.days.ago }
    end
  end

end