Chargify.configure do |c|
    c.subdomain = APP_CONFIG['chargify']['subdomain']
    c.api_key = APP_CONFIG['chargify']['api_key']
end