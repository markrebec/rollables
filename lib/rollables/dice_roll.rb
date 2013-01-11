module Rollables
  class DiceRoll < Array
    attr_reader :dice, :drop, :modifiers, :timestamp

    def dropped
      sort.slice(0,@drop.count)
    end

    def kept
      sort.slice(-(length - @drop.count))
    end

    def modifier=(modifier)
      @modifiers << RollModifier.new(modifier)
    end

    def result
      if @modifiers.nil? || @modifiers.empty?
        @dice.numeric? ? collect(&:result).flatten.sum : collect(&:result).join(",")
      else
        modified_result = (@dice.numeric? ? collect(&:result).flatten.sum : collect(&:result))
        @modifiers.each { |modifier| modified_result = modifier.call(modified_result) }
        @dice.numeric? ? modified_result : modified_result.join(",")
      end
    end
    alias_method :total, :result
    alias_method :to_i, :result

    def results
      if @modifiers.nil? || @modifiers.empty?
        collect(&:results)
      else
        modified_results = collect(&:results)
        @modifiers.each { |modifier| modified_results << modifier }
        modified_results
      end
    end
    alias_method :inspect, :results

    def to_s
      result.to_s
    end

    protected
    
    def initialize(dice, drop=nil, &block)
      @dice = dice.clone
      @drop = @dice.drop
      @drop << RollDrop.new(drop) unless drop.nil?
      @modifiers = []
      @modifiers << @dice.modifier if @dice.modifier?
      @modifiers << RollModifier.new(block) if block_given?
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
