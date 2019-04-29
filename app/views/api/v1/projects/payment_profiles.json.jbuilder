json.array! @payment_profiles do |payment_profile|

  json.id payment_profile.id
  json.name payment_profile.name
  json.expected_cost_cents payment_profile.expected_cost_cents
  json.expected_payment_date payment_profile.expected_payment_date

end