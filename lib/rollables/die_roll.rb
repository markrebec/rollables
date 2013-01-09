module Rollables
  class DieRoll
    attr_reader :die, :modifiers, :timestamp
    
    def modifier=(modifier)
      @modifiers << RollModifier.new(modifier)
    end

    def result
      if @modifiers.nil? || @modifiers.empty?
        @result
      else
        modified_result = @result
        @modifiers.each { |modifier| modified_result = modifier.call(modified_result) }
        modified_result
      end
    end
    alias_method :value, :result
    #alias_method :inspect, :result
    
    def results
      if @modifiers.nil? || @modifiers.empty?
        @result
      else
        modified_result = [@result]
        @modifiers.each { |modifier| modified_result << modifier.to_s }
        modified_result
      end
    end

    def to_s
      "#{@die.to_s}=#{result.to_s}"
    end

    protected

    def initialize(die, modifiers=[])
      @die = die
      @modifiers = modifiers
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
