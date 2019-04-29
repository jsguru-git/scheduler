module DocumentsHelper
  include CustomDateTimeHelper
  def summary_helper(document)
    o = (document.is_local? ? 'Uploaded' : 'Attached')
    o << " by: #{ document.user.name }" if document.user.present?
    o << " on #{ fmt_long_date document.created_at }"
  end

  def provider_name_helper(document)
    "Stored on: #{ document.is_local? ? 'FleetSuite' : document.provider.capitalize }"
  end
end
