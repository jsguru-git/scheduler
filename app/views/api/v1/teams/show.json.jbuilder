json.id @team.id
json.name @team.name
json.users @team.users do |user|
  json.id user.id
  json.firstname user.firstname
  json.lastname user.lastname
end