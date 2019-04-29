module ApplicationHelper


  # Only use ssl in production mode
  def ssl_link
    if Rails.env == 'production' || Rails.env == 'staging'
      'https://'
    else
      'http://'
    end
  end

  # Sort by value
  #
  # column - DB column to sort by
  # title  - Title of the link
  # 
  # Returns a link to sort the current page
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    if column == params[:sort]
      link_to title, { sort: column, direction: direction }, class: params[:direction]
    else
      link_to title, sort: column, direction: direction
    end
  end

  def avatar(user, size)
    image = user.gravatar_url(:size => size, :secure => request.ssl?, :default => 404)

    begin
      response = HTTParty.get(image, timeout: 5)
      if response.code == 404
        link_to user_path(user) do
          content_tag :div, "#{ user.firstname.first }#{ user.lastname.first }", class: 'avatar avatar_initials', title: user.name
        end
      else
        content_tag :div, link_to(image_tag(image, :alt => user.firstname, :class => 'user_image', :title => user.name), user_path(user)), class: 'avatar'
      end
    rescue Timeout::Error
      content_tag :div, "#{ user.firstname.first }#{ user.lastname.first }", class: 'avatar avatar_initials', title: user.name
    end
  end

  # display a spinner tag
  def spinner_tag(id)
    image_tag("tool/ajax/ajax_spinner.gif", :id => id, :alt => "Loading....", :style => "display:none;")
  end

  # Take out the following currencies as the currency api doesnt support them CUC, ERN, SKK, TMM, ZWD
  def supported_currencies(hash)
    non_supported = ['CUC', 'ERN', 'SKK', 'TMM', 'ZWD', 'JPY', 'BAM']
    hash.delete_if {|key, attributes| attributes[:iso_code] && non_supported.include?(attributes[:iso_code]) }
    hash
  end

  def s3_image(image_url, options = {})
    "#{ options[:protocol] }#{ image_url.split('//').last }"
  end
end

