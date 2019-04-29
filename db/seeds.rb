# Create Roles

['account_holder', 'administrator', 'leader', 'member'].each do |role|
  if Role.find_by_title(role).blank?
    Role.create(title: role)
  end
end
