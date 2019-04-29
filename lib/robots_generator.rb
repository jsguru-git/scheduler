class RobotsGenerator
  def self.call(env)
    body = if APP_CONFIG['env_config']['robots'] == true
      File.read Rails.root.join('config', 'robots.txt')
    else
      "User-agent: *\nDisallow: /"
    end

    headers = { 'Cache-Control' => "public, max-age=#{1.month.seconds.to_i}" }

    [200, headers, [body]]
  rescue Errno::ENOENT
    [404, {}, ['# A robots.txt is not configured']]
  end
end