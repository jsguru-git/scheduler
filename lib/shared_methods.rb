# Shared across all models to keep code DRY

module SharedMethods

  # includes
  def self.included(base)
    base.send(:include, InstanceMethods)
  end


  # Class method
  module InstanceMethods

   # Remove white space from end of strings
   def remove_whitespace
     self.attributes.each do |key,value|
       if value.kind_of?(String) && !value.blank? && !key.include?('password')
          write_attribute key, value.strip
        end
      end
    end
  end
end
