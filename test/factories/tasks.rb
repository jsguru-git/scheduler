FactoryGirl.define do

  factory :task do
    sequence :name do |n|
      "factorytask#{n}"
    end

    description  'task description'
    project
    estimated_minutes 120
    count_towards_time_worked true
  end

  trait :quoted do
    quote_activity_id 1
  end

  trait :not_quoted do
    quote_activity_id nil
  end

end