module Rollables
  class DiceRoll < Array
    attr_accessor :drop
    attr_reader :dice, :modifiers, :timestamp

    def modifier=(modifier)
      @modifiers << RollModifier.new(modifier)
    end

    def result
      if @modifiers.nil? || @modifiers.empty?
        @dice.numeric? ? collect(&:result).flatten.sum : collect(&:result)
      else
        modified_result = (@dice.numeric? ? collect(&:result).flatten.sum : collect(&:result))
        @modifiers.each { |modifier| modified_result = modifier.call(modified_result) }
        modified_result
      end
    end
    alias_method :value, :result
    #alias_method :inspect, :result

    def results
      if @modifiers.nil? || @modifiers.empty?
        collect(&:results)
      else
        modified_results = collect(&:results)
        @modifiers.each { |modifier| modified_results << modifier.to_s }
        modified_results
      end
    end

    def to_s
      if @dice.numeric?
        "(#{collect { |roll| roll.to_s }.join(" + ")}) = (#{collect(&:result).join("+")} = #{collect(&:result).flatten.sum})"
      else
        "(#{collect { |roll| roll.to_s }.join(" + ")}) = (#{join(",")})"
      end
    end

    protected
    
    def initialize(dice, modifiers=[])
      @dice = dice
      @modifiers = modifiers
      @result = nil
      roll
    end

    def roll
      @dice.each { |die| self << die.roll }
      @timestamp = Time.now
    end
  end

  class DiceRolls < Array
    def to_s
      join(", ")
    end
  end
end
