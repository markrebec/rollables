module Rollables
  class DieRoll
    attr_accessor :modifier
    attr_reader :die, :timestamp
   
    def result
      @modifier.nil? ? @result : @modifier.call(@result)
    end
    alias_method :value, :result
    alias_method :inspect, :result
    
    def to_s
      "#{die.to_s}=#{result.to_s}"
    end

    protected

    def initialize(die, &block)
      @die = die
      @modifier = block if block_given?
      roll
    end

    def roll
      @result = @die.sample
      @timestamp = Time.now
    end
  end

  class DieRolls < Array
    def to_s
      join(",")
    end
  end
end
