module Utils
  def self.to_regex(path)
    segments = []
    while !path.empty?
      if path[0...2] == '**'
        segments << '.*'
        path = path[2..-1]
      elsif path[0...1] == '*'
        segments << '[^/]*'
        path = path[1..-1]
      else
        next_star = path.index("*") || path.length
        segments << Regexp.escape(path[0...next_star])
        path = path[next_star..-1]
      end
    end
    segments.join
  end
end

USER_CONFIG = "/app/static.json"

config = {}
config = JSON.parse(File.read(USER_CONFIG)) if File.exist?(USER_CONFIG)
req    = Nginx::Request.new
uri    = req.var.uri

if config["headers"]
  config["headers"].to_a.reverse.each do |route, header_hash|
    if Regexp.compile("^#{Utils.to_regex(route)}$") =~ uri
      header_hash.each do |key, value|
        # value must be a string
        req.headers_out[key] = value.to_s
      end
      break
    end
  end
end
