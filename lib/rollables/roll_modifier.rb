module Rollables
  class RollModifier
    attr_accessor :modifier

    def self.new(modifier)
      return nil if modifier.nil? || modifier.to_s.empty?
      super
    end

    def call(roll_result)
      @modifier.stringy? ? eval("#{roll_result}#{@modifier}") : @modifier.call(roll_result)
    end

    def to_s
      @modifier.to_s
    end

    protected

    def initialize(modifier)
      @modifier = modifier
    end
  end
end
