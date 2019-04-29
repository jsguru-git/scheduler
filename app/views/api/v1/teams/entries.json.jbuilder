json.array! @entries do |entry|

  json.id entry.id
  json.user_id entry.user_id
  json.project_id entry.project_id
  json.start_date entry.start_date
  json.end_date entry.end_date

end
