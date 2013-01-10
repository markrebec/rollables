module Rollables
  class RollModifier
    attr_accessor :modifier

    def self.new(modifier)
      return nil if modifier.nil? || modifier.to_s.empty?
      super
    end

    def call(roll_result)
      @modifier.stringy? ? eval("#{roll_result}#{@modifier}") : (@modifier.respond_to?(:call) ? @modifier.call(roll_result) : roll_result)
    end

    def to_s
      @modifier.respond_to?(:call) ? @modifier.to_source : @modifier.to_s
    end

    protected

    def initialize(modifier)
      @modifier = modifier
    end

    def initialize_copy(other)
      @modifier = other.modifier.clone unless other.modifier.nil?
    end
  end
end
