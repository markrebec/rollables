module Rollables
  class Dice < Array
    attr_reader :rolls

    def add_dice(dice)
      assign_dice(dice)
      self
    end
    alias_method :add_die, :add_dice

    def common?
      all? { |die| die.common? }
    end

    def has_nested?
      all? { |die| die.is_a?(Dice) }
    end

    def high
      numeric? ? highs.sum : highs
    end

    def highs
      collect &:high
    end

    def low
      numeric? ? lows.sum : lows
    end

    def lows
      collect &:low
    end

    def notation
      return DieNotationArray.new(map { |die| die.notation })
    end

    def numeric?
      all? { |die| die.numeric? }
    end

    def roll(&block)
      raise "A set of Dice must contain at least 1 Die" unless length > 0
      @rolls << DiceRoll.new(self, &block)
      @rolls.last
    end

    def sequential?
      all? { |die| die.sequential? }
    end

    def simple?
      all? { |die| die.simple? }
    end

    def to_s
      notation.flatten.reduce.to_s
    end

    protected

    def assign_dice(*dice)
      dice = [dice] unless dice.is_a?(Array) && !dice.is_a?(Die) #&& !dice.is_a?(self.class)
      dice.each { |die| (die.is_a?(Array) && !die.is_a?(Die) && !die.is_a?(self.class)) ? die.each { |d| assign_die(d) } : assign_die(die) }
    end

    def assign_die(die)
      (die.is_a?(Die) || die.is_a?(self.class)) ? self << die : assign_notation(die)
    end

    def assign_notation(notation)
      if notation.stringy? && notation.to_s.match(/\s/)
        dice = self.class.new
        notation.split(/\s+/).each do |n|
          dnotation = DieNotation.new(n)
          dnotation.dice.times { dice.add_dice(Die.new(dnotation.singular)) }
          # TODO add drop/modifier
        end
        self << dice
      else
        notation = DieNotation.new(notation) unless notation.is_a?(DieNotation)
        if notation.drop? || notation.modifier?
          dice = self.class.new
          notation.dice.times { dice.add_dice(Die.new(notation.singular)) }
          # TODO add drop/modifier
          self << dice
        elsif notation.dice > 1
          notation.dice.times { self << Die.new(notation.singular) }
        else
          self << Die.new(notation)
        end
      end
    end

    def initialize(*dice)
      assign_dice(*dice)
      @rolls = DiceRolls.new
    end
  end

  class DiceRoll
    attr_accessor :modifier
    attr_reader :results, :timestamp

    def result
      @modifier.nil? ? @results.collect(&:result) : @modifier.call(@results.collect(&:result))
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
