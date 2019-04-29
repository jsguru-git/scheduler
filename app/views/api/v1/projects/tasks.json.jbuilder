json.array! @tasks do |task|

  json.id task.id
  json.name task.name
  json.estimated_minutes task.estimated_minutes

end