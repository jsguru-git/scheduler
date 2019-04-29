FactoryGirl.define do

  factory :project do
    sequence :name do |n|
      "factoryproject#{n}"
    end

    description  'project_description'
    archived 0
    account

      factory :opportunities do

        project_status 'opportunity'

        factory :stale_opportunity do
          updated_at { 3.weeks.ago }
        end

        factory :not_stale_opportunity do
          updated_at { 1.week.ago }
        end

      end

  end

end