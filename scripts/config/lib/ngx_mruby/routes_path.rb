module Utils
  def self.parse_routes(json)
    routes = json.map do |route, target|
      [to_regex(route), target]
    end

    Hash[routes]
  end

  def self.match_proxies(proxies, uri)
    return false unless proxies

    matched = proxies.select do |proxy|
      Regexp.compile("^#{proxy}") =~ uri
    end

    # return the longest matched proxy
    if matched.any?
      matched.max_by {|proxy| proxy.size }
    else
      false
    end
  end

  def self.match_redirects(redirects, uri)
    return false unless redirects

    redirects.each do |redirect|
      return redirect if redirect == uri
    end

    false
  end
end

USER_CONFIG = "/app/static.json"

config      = {}
config      = JSON.parse(File.read(USER_CONFIG)) if File.exist?(USER_CONFIG)
req         = Nginx::Request.new
uri         = req.var.uri
nginx_route = req.var.route
routes      = Utils.parse_routes(config["routes"])
proxies     = config["proxies"] || {}
redirects   = config["redirects"] || {}

if Utils.match_proxies(proxies.keys, uri) || Utils.match_redirects(redirects.keys, uri)
  # this will always fail, so try_files uses the callback
  uri
else
  "/#{routes[nginx_route]}"
end
