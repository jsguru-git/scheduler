class ProjectMailer < ActionMailer::Base

  layout 'email'
  default from: APP_CONFIG['main']['from-email']

  def stale_opportunity_mail(account, manager, project)
    @account = account
    @manager = manager
    @project = project
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']
    
    to_email = ''
    to_email += @manager.email if @manager.present?
    to_email += ', ' + account.account_setting.stale_opportunity_email if account.account_setting.stale_opportunity_email.present?

    mail(:to => MailerTasks.recipients(to_email),
         :subject => MailerTasks.rendered_subject(APP_CONFIG['env_config']['site_name'] + ' - Stale Opportunity')).deliver
  end
  
  def project_budget_email(project, account_setting, percentage_over)
    @project = project
    @percentage_over = percentage_over
    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']
    
    to_email = ''
    to_email += project.project_manager.email if project.project_manager.present?
    to_email += ', ' + account_setting.budget_warning_email if account_setting.budget_warning_email.present?
    
    mail(:to => MailerTasks.recipients(to_email), 
         :subject => MailerTasks.rendered_subject("#{APP_CONFIG['env_config']['site_name']} project gone over #{percentage_over}% budget"))
  end

  def unquoted_activity_email(task)
    @task = task

    @site_host = APP_CONFIG['env_config']['site_host']
    @site_name = APP_CONFIG['env_config']['site_name']

    to_email = ''
    to_email += task.project.project_manager.email if task.project.project_manager.present?
    to_email += ', ' + task.project.account.account_setting.budget_warning_email if task.project.account.account_setting.budget_warning_email.present?

    mail(:to => MailerTasks.recipients(to_email),
         :subject => MailerTasks.rendered_subject("#{ APP_CONFIG['env_config']['site_name'] }: New unquoted activity has been created"))
  end

  def overrun_task(task)
    @task = task

    @site_host = APP_CONFIG['main']['site-host']
    @site_name = APP_CONFIG['main']['site-name']

    to_email = ''
    to_email += task.project.project_manager.email if task.project.project_manager.present?
    to_email += ', ' + task.project.account.account_setting.budget_warning_email if task.project.account.account_setting.budget_warning_email.present?

    mail(to: Rails.env.production? ? to_email : 'fleetsuite@arthurly.com',
         subject: MailerTasks.rendered_subject("#{ APP_CONFIG['main']['site-name'] }: Task has overrun"))
  end
end
