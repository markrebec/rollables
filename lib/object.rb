class Object
  def stringy?
    is_a?(Integer) || is_a?(String) || is_a?(Symbol)
  end
end
