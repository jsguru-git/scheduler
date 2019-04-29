module CustomNavigationHelper


  def tab_class(tab_name, first = false)
    active_class = first ? 'first_active' : 'active'
    case tab_name
    when 'dashboard' then
      if params[:controller] == 'dashboards'
        return active_class
      end
    when 'time' then
      if params[:controller] == 'track/timings' || params[:controller] == 'schedule/entries'
        return active_class
      end
    when 'people' then
      if params[:controller] == 'users' || params[:controller] == 'clients' || (params[:controller] == 'teams')
        return active_class
      end
    when 'projects' then
      if params[:controller] == 'projects' || (params[:project_id] && !params[:controller].include?('reports/'))
        return active_class
      end
    when 'reports' then
      if params[:controller].include? 'reports/'
        return active_class
      end
    end
  end


  def account_settings_second_nav(current_page)
    [{:title => 'Upgrade', :url => account_settings_url(:protocol => ssl_link), :class => current_page == 'index' ? 'active' : ''},
     {:title => 'Payment details', :url => payment_details_account_settings_url(:protocol => ssl_link), :class => current_page == 'payment_details' ? 'active' : ''},
     {:title => 'Statements', :url => statements_account_settings_url(:protocol => ssl_link), :class => current_page == 'statements' ? 'active' : ''}]
  end
    
  

  #
  #
  def client_second_nav(client, current_page)
    [{:title => 'Overview', :url => client_path(client), :class =>  params[:action] == 'show' ? 'active' : ''},
     {:title => 'Rate card', :url => client_client_rate_cards_path(client), :class => current_page == 'rate_card' ? 'active' : ''}]
  end
    
  
  #
  #
  def people_second_nav(current_page)
    h_nav = []
    h_nav << { :title => 'Employees', :url => users_url(:protocol => ssl_link), :class => params['controller']  == 'users' ? 'active' : '' }
    h_nav << { :title => 'Teams', :url => teams_url(:protocol => ssl_link), :class => params['controller'] == 'teams' ? 'active' : '' }
    h_nav << { :title => 'Clients', :url => clients_url(:protocol => ssl_link), :class => params['controller']  == 'clients' ? 'active' : '' } if policy(Client).read?

    h_nav
  end
  
    

  #
  #
  def settings_second_nav(current_page)
    h_nav = []
    h_nav << {:title => 'System settings', :url => settings_url(:protocol => ssl_link), :class =>  params[:controller] == 'settings' && current_page == 'index' ? 'active' : ''}
    h_nav << {:title => 'Personal settings', :url => personal_settings_url(:protocol => ssl_link), :class =>  params[:controller] == 'settings' && current_page == 'personal' ? 'active' : ''}
    h_nav << {:title => 'Quote settings', :url => quote_settings_url(:protocol => ssl_link), :class => params[:controller] == 'settings' && current_page == 'quote'  ? 'active' : ''}  if @account.component_enabled?(3)
    h_nav << {:title => 'Schedule settings', :url => schedule_settings_url(:protocol => ssl_link), :class => params[:controller] == 'settings' && current_page == 'schedule'  ? 'active' : ''}  if @account.component_enabled?(1)
    h_nav << {:title => 'Invoice settings', :url => invoice_settings_url(:protocol => ssl_link), :class => params[:controller] == 'settings' && current_page == 'invoice'  ? 'active' : ''}  if @account.component_enabled?(4)
    h_nav << {:title => 'Issue tracker', :url => issue_tracker_settings_url(:protocol => ssl_link), :class => params[:controller] == 'settings' && current_page == 'issue_tracker'  ? 'active' : ''}
    h_nav << {:title => 'Default rate card', :url => rate_cards_url(:protocol => ssl_link), :class => params[:controller] == 'rate_cards' ? 'active' : ''}
  end

  # 
  #
  def time_management_second_nav(current_page)
    h_nav = []
    if has_permission?('account_holder || administrator') && @account.component_enabled?(2)
      h_nav << { :title => 'User Timesheet', :url => track_timings_path({:user_view=>1}), :class => params['action'] == 'index' && params['controller'] == 'track/timings' && params[:user_view].present? ? 'active' : '' }
      h_nav << { :title => 'Team Timesheet', :url => track_timings_path, :class => params['action'] == 'index' && params['controller'] == 'track/timings' && params[:user_view].blank? ? 'active' : '' }
    elsif @account.component_enabled?(2)
      h_nav << {:title => 'Timesheet', :url => track_timings_path, :class => params['action'] == 'index' && params['controller'] == 'track/timings' ? 'active' : ''}
    end
    h_nav << { :title => 'Schedule', :url => schedule_entries_path, :class => params['action'] == 'index' && params['controller'] == 'schedule/entries' ? 'active' : '' } if @account.component_enabled?(1)
    h_nav << { :title => 'Next Available', :url => lead_time_schedule_entries_path, :class => current_page == 'lead_time' ? 'active' : '' } if has_permission?('account_holder || administrator') if @account.component_enabled?(1)
    h_nav << { :title => 'Submitted time report', :url => submitted_time_report_track_timings_path, :class => params['action']  == 'submitted_time_report' ? 'active' : '' } if @account.component_enabled?(2)

    h_nav
  end
    
    
  def project_second_nav(project, current_page)
    h_nav = []
    h_nav << {:title => 'Overview', :url => project_path(project), :class => current_page == 'show' ? 'active' : ''}
    h_nav << {:title => 'Quotes', :url => quote_project_quotes_path(project), :class => current_page  == 'quote' ? 'active' : ''} if @account.component_enabled?(3) && policy(Quote).read?
    h_nav << {:title => 'Activities', :url => project_tasks_path(project), :class => params['controller'] == 'tasks' ? 'active' : ''} if policy(Feature).read?
    h_nav << {:title => 'Schedule', :url => schedule_project_path(project), :class => current_page  == 'schedule' ? 'active' : ''} if @account.component_enabled?(1)
    if @account.component_enabled?(2)
      h_nav << {:title => 'Tracking', :url => track_project_path(project), :class => current_page  == 'track' ? 'active' : ''}
    end
    if has_permission?('account_holder || administrator') && @account.component_enabled?(4)
      h_nav << {:title => 'Payment profile', :url => invoice_project_payment_profiles_path(project), :class => current_page  == 'payment' ? 'active' : ''}
      h_nav << {:title => 'Invoicing', :url => invoice_project_invoices_path(project), :class => current_page  == 'invoice' ? 'active' : ''}
    end
    h_nav << {:title => 'Documents', :url => project_documents_path(project), :class => current_page == 'documents' ? 'active' : ''} if policy(Document).read?
    h_nav << {:title => 'Discussion', :url => project_project_comments_path(project), :class => current_page == 'project_comments' ? 'active' : ''} if policy(ProjectComment).read?

    h_nav
  end

  #
  # gives the correct css class depending on if there is a second menu
  def inner_content_class
    if @second_nav
      'with_second_nav'
    else
      ''
    end
  end
  
  
end
