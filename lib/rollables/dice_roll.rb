module Rollables
  class DiceRoll
    attr_accessor :drop
    attr_reader :dice, :modifiers, :timestamp

    def modifier=(modifier)
      @modifiers << RollModifier.new(modifier)
    end

    def result
      if @modifiers.nil? || @modifiers.empty?
        @dice.numeric? ? @results.collect(&:result).flatten.sum : @results.collect(&:result)
      else
        modified_result = (@dice.numeric? ? @results.collect(&:result).flatten.sum : @results.collect(&:result))
        @modifiers.each { |modifier| modified_result = modifier.call(modified_result) }
        modified_result
      end
    end
    alias_method :value, :result
    #alias_method :inspect, :result

    def results
      if @modifiers.nil? || @modifiers.empty?
        @results.collect(&:results)
      else
        modified_results = @results.collect(&:results)
        @modifiers.each { |modifier| modified_results << modifier.to_s }
        modified_results
      end
    end

    def to_s
      if @dice.numeric?
        "(#{@results.collect { |roll| roll.to_s }.join(" + ")}) = (#{@results.collect(&:result).join("+")} = #{@results.collect(&:result).flatten.sum})"
      else
        "(#{@results.collect { |roll| roll.to_s }.join(" + ")}) = (#{@results.join(",")})"
      end
    end

    protected
    
    def initialize(dice, modifiers=[])
      @dice = dice
      @modifiers = modifiers
      @results = []
      @result = nil
      roll
    end

    def roll
      @dice.each { |die| @results << die.roll }
      @timestamp = Time.now
    end
  end

  class DiceRolls < Array
    def to_s
      join(", ")
    end
  end
end
