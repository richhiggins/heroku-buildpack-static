module Utils
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

config    = {}
config    = JSON.parse(File.read(USER_CONFIG)) if File.exist?(USER_CONFIG)
req       = Nginx::Request.new
uri       = req.var.uri
proxies   = config["proxies"] || {}
redirects = config["redirects"] || {}

if proxy = Utils.match_proxies(proxies.keys, uri)
  "@#{proxy}"
elsif redirect = Utils.match_redirects(redirects.keys, uri)
  "@#{redirect}"
else
  "@404"
end
