class Flash

  def initialize(session)
    @session = session
    @flash = @session['flash'] ||= {}
  end

  def [](key)
    @flash[key]
  end

  def []=(key, val)
    @flash[key] = val
  end

end