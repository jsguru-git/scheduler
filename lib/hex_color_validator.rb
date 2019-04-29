# Validates a hexadecimal color string as defined in the HTML 5 spec.
# This validator only works for the simple case and does not support
# any legacy formats. See http://dev.w3.org/html5/spec/Overview.html#valid-simple-color
# for the format spec.
class HexColorValidator < ActiveModel::EachValidator
    # Verifies a color string is 7 characters long and contains
    # only hex values after the pound sign.
    def validate_each(object, attribute, value)
        if value.present?
            unless value =~ /^#[0-9a-fA-F]{6}$/
                object.errors[attribute] << (options[:message] || " is not a properly formatted color string")
            end
        end
    end
end