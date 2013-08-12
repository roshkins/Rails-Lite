class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    self.pattern =~ req.path &&
      req.request_method.downcase.to_sym == self.http_method
  end

  def run(req, res)
    params = req.path.match(pattern).regexp.named_captures
    controller_class.new(req, res, params).invoke_action(self.action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    self.routes.each { |route| return route if route.matches?(req) }
    nil
  end

  def run(req, res)
    if self.match(req).nil?
      res.status = 404
    else
      self.match(req).run(req, res)
    end
  end
end
