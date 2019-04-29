module Breadcrumbs
  class Breadcrumb
    attr_accessor :title, :link
  
    def initialize(title, link)
      @title = title
      @link = link
    end
  end
end