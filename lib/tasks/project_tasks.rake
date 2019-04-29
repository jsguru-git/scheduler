namespace :project do

  desc "Updates the project status"
  task(:update_status => :environment) do
    Project.all.each do |p|
      p.save
    end
  end

  desc "Inform project owners of stale opportunities"
  task(:inform_project_owners_of_stale_opportunities => :environment) do
    projects = Project.stale_opportunities
    projects.each { |project| ProjectMailer.stale_opportunity_mail(project.account, project.project_manager, project) if project.project_manager.present? || project.account.account_setting.stale_opportunity_email.present? }
  end
  
  desc "Send project budget emails"
  task(:send_project_budget_email => :environment) do
    Project.send_project_budget_email
  end

end
