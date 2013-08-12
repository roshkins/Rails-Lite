require 'uri'
require 'debugger'

class Params
  def initialize(req, route_params)
    @params = {}
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)
    @params = @params.merge(route_params)

  end

  def [](key)
    @params[key.to_s]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    if www_encoded_form
      URI.decode_www_form(www_encoded_form).each do |pair|
        p_key = parse_key(pair.first)
        the_hash = @params ||= {}
        @params = the_hash
        p_key[0..-2].each do |key|
          the_hash = the_hash[key] ||= {}
        end
        the_hash[p_key.last] = pair.last
      end
    end
  end

  def parse_key(key)
    key.gsub("]", "").split("[")
  end
end
