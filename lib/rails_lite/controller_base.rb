require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(@req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= session[:flash]
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    unless already_rendered?
      session.store_session(@res)
      @res["Location"] = url
      @res.status = 302
      @already_rendered = true
      @flash = nil
    else
      raise "Double render encountered in redirect_to."
    end
  end

  def render_content(body, content_type)
    unless already_rendered?
      session.store_session(@res)
      @res.content_type = content_type
      @res.body         = body
      @already_rendered = true
      @flash = nil
    else
      raise "Double render encountered in render_content."
    end
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    template_name = template_name.to_s.underscore
    template_text = File.read("views/#{controller_name}/#{template_name}.html.erb")
    rendered_erb = ERB.new(template_text)
    render_content(rendered_erb.result(binding), "text/html")
  end

  def invoke_action(name)
    self.send(name)
    self.render(name) unless already_rendered?
  end
end
