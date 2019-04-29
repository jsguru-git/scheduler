json.array! @projects do |project|
  json.id project.id
  json.archived project.archived
  json.client_id project.client_id
  json.description project.description
  json.name project.name
  json.status project.project_status
  json.team_id project.team_id
  json.rag_status project.current_rag_status
  json.percentage_complete project.percentage_complete
  json.total_budget project.total_project_cost_cents
  json.predictions do
      json.data Project.payment_prediction_totals(project.account, {}, 1.month.ago, Time.now)
  end
end