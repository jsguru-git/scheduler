json.array! @timings do |timing|

  json.id timing.id
  json.duration timing.duration_minutes
  json.submitted timing.submitted
  json.task_id timing.task_id
  json.started_at timing.started_at
  json.ended_at timing.ended_at
  json.billable timing.task.count_towards_time_worked

end