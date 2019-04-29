namespace :chargify do

  # Imports all products from chargify
  task(:import_all_product_details => :environment) do
    AccountPlan.update_plan_details_from_chargify
    AccountComponent.update_component_details_from_chargify
  end
end
