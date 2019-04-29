unless Rails.env.test?
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_protocol] = ''
  Paperclip::Attachment.default_options[:s3_credentials] = {
    :bucket => "fleetsuite_#{ Rails.env }",
    :access_key_id => APP_CONFIG['secrets']['s3']['access_key_id'],
    :secret_access_key => APP_CONFIG['secrets']['s3']['secret_access_key']
  }
end