module Rollables
  class DieRoll
    attr_reader :die, :result, :timestamp
    alias_method :results, :result
    alias_method :total, :result
    
    def to_s
      @result.to_s
    end

    protected

    def initialize(die)
      @die = die
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
