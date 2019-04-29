class FrontApplicationController < ApplicationController


  # Layout
  layout 'front'


  # Callbacks
  before_filter :ensure_correct_protocol
  before_filter :dont_allow_subdomain


protected



  #
  # Don't allow subdomains to view a page
  def dont_allow_subdomain
    raise ActiveRecord::RecordNotFound if request.subdomain.present? && request.subdomain != "www"
  end


end
