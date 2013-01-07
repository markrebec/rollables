module Rollables
  class DiceRoll
    attr_accessor :modifier
    attr_reader :results, :timestamp

    def result
      @modifier.nil? ? @results.map(&:result) : @modifier.call(@results.map(&:result))
    end
    alias_method :value, :result
    alias_method :inspect, :result

    def to_s
      if @dice.numeric?
        "(#{@results.collect { |roll| roll.to_s }.join(" + ")}) = (#{result.join("+")} = #{result.flatten.sum})"
      else
        "(#{@results.collect { |roll| roll.to_s }.join(" + ")}) = (#{result.join(",")})"
      end
    end

    protected
    
    def initialize(dice, &block)
      @dice = dice
      @modifier = block if block_given?
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
