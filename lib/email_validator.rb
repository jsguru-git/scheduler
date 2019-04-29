class EmailValidator < ActiveModel::EachValidator
  
  
  # Public: Custom validator to check that a comma seperated string of email addresses only contains valid addresses.
  #
  # record {object} The validating object
  # attribute {symbol} The validating attribute
  # value {String} The validating value
  def validate_each(record, attribute, value)
    if value.present?
      email_addresses = value.split(%r{,\s*})
      
      email_addresses.each do |email_address|
        # Old regex /^([A-z0-9\.\-_]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
        unless email_address =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          record.errors[attribute] << (options[:message] || "contains an invalid email address")
          break
        end
      end
    end
  end
  
  
end