module PagesHelper


  #
  # Set class for the product name
  def product_nav_active(tab_name)
    if params[:from].present? && tab_name == params[:from]
      return 'active'
    end

    case tab_name
    when 'home' then
      if (params[:controller] == 'pages' && (params[:action] == 'index' || (params[:action] == 'signup' && params[:from].blank?)) || params[:controller] == 'accounts')
        return 'active'
      end
    when 'quote' then
      if params[:controller] == 'pages' && params[:action] == 'quote_tool'
        return 'active'
      end
    when 'schedule' then
      if params[:controller] == 'pages' && params[:action] == 'scheduling_tool'
        return 'active'
      end
    when 'track' then
      if params[:controller] == 'pages' && params[:action] == 'time_tracking_tool'
        return 'active'
      end
    when 'invoice' then
      if params[:controller] == 'pages' && params[:action] == 'invoice_tool'
        return 'active'
      end
    end

  end


  #
  # Second nav bar for fleetsuite
  def fleetsuite_second_nav(current_page)
    [{:title => 'Home', :url => root_path, :class => current_page == 'home' ? 'active' : ''},
    {:title => 'Pricing & Signup', :url => pricing_path, :class => current_page == 'signup' ? 'active' : ''}]
  end
  
  
  #
  # Second nav bar for estimate
  def quote_second_nav(current_page)
    [{:title => 'Tour', :url => quote_tool_path, :class => current_page == 'home' ? 'active' : ''},
    {:title => 'Pricing & Signup', :url => pricing_path(:from => 'quote'), :class => current_page == 'signup' ? 'active' : ''}]
  end


  #
  # Second nav bar for schedule
  def schedule_second_nav(current_page)
    [{:title => 'Tour', :url => scheduling_tool_path, :class => current_page == 'home' ? 'active' : ''},
    {:title => 'Pricing & Signup', :url => pricing_path(:from => 'schedule'), :class => current_page == 'signup' ? 'active' : ''}]
  end


  #
  # Second nav bar for track
  def track_second_nav(current_page)
    [{:title => 'Tour', :url => time_tracking_tool_path, :class => current_page == 'home' ? 'active' : ''},
    {:title => 'Pricing & Signup', :url => pricing_path(:from => 'track'), :class => current_page == 'signup' ? 'active' : ''}]
  end
  
  
  #
  # Second nav bar for estimate
  def invoice_second_nav(current_page)
    [{:title => 'Tour', :url => invoice_tool_path, :class => current_page == 'home' ? 'active' : ''},
    {:title => 'Pricing & Signup', :url => pricing_path(:from => 'invoice'), :class => current_page == 'signup' ? 'active' : ''}]
  end


end
