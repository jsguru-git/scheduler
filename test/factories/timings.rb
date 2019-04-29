FactoryGirl.define do

  factory :timing do
    task
    user
    project

    started_at { 1.week.ago }
    ended_at { 6.days_ago }
  end

end