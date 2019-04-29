module Breadcrumbs
  class Navigation
    
    attr_accessor :breadcrumbs

    def initialize
      @breadcrumbs = []
    end

    # Adds a Breadcrumb to the menu
    #
    # title - title of link
    # url - url of link
    #
    # Returns the updated Array of Breadcrumbs
    def add_breadcrumb(title, url)
      @breadcrumbs << Breadcrumb.new(title, url)
    end

  end
end