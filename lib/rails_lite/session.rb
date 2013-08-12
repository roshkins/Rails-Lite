require 'json'
require 'webrick'

class Session
  def initialize(req)
    @parsed_json = {}
    req.cookies.each do |cookie|
      @parsed_json = JSON.parse(cookie.value)  if cookie.name == "_rails_lite_app"
    end
  end

  def [](key)
    @parsed_json[key]
  end

  def []=(key, val)
    @parsed_json[key] = val
  end

  def store_session(res)
    cookie = WEBrick::Cookie.new("_rails_lite_app", @parsed_json.to_json)
    res.cookies << cookie
  end
end
