module CustomHtmlTagHelper


  def front_metadata_title
    ( @page_title ? strip_tags(@page_title) : APP_CONFIG['main']['site-default-title'])
  end


  def tool_metadata_title
    @account.site_address + (@page_title ? ' - ' + strip_tags(@page_title) : '')
  end


  def metadata_description
    return h(@page_description ? truncate_for_meta_description(@page_description) : APP_CONFIG['main']['site-description'])
  end


  def metadata_keywords
    return h(@page_keywords ? @page_keywords : APP_CONFIG['main']['site-keywords'])
  end


  def body_id
    return "#{params[:controller].delete('/')}_#{params[:action]}"
  end


  # Meta description should be between 25 - 30 words.
  def truncate_for_meta_description(string, pi_number = 30)
    unless string.blank?
      strip_tags(string)
    end
  end


end
