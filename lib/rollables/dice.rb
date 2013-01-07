module Rollables
  class Dice < Array
    attr_reader :rolls

    def add_dice(*dice)
      assign_dice(*dice)
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
      return Notations::Dice.new(map { |die| die.notation })
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
      dice.each do |die|
        if die.is_a?(self.class) || die.is_a?(Die)
          self << die
        elsif die.is_a?(Notations::Die)
          assign_die_notation(die)
        elsif die.is_a?(Notations::Dice)
          assign_die_notation_array(die)
        elsif die.is_a?(Array) && die.all? { |d| d.is_a?(Die) || d.is_a?(Dice) }
          die.each { |d| self << d }
        else
          assign_dice(Notations::Die.parse(die))
        end
      end
    end
    
    def assign_die_notation(notation)
      if notation.drop? || notation.modifier?
        self << ((notation.dice > 1) ? self.class.new(notation.dice.times.map { Die.new(notation.singular) }) : Die.new(notation))
      else
        notation.dice > 1 ? notation.dice.times.map { self << Die.new(notation.singular) } : self << Die.new(notation)
      end
    end
    
    def assign_die_notation_array(notation_array)
      dice = self.class.new
      notation_array.each do |notation|
        dice.add_dice(notation)
      end
      self << dice
      #self << self.class.new(notation_array.map { |notation| (notation.is_a?(Notations::Die)) ? (notation.dice > 1 ? self.class.new(notation.dice.times.map { |n| Die.new(n) }) : Die.new(notation)) : self.class.new(notation) })
    end

    def initialize(*dice)
      assign_dice(*dice)
      @rolls = DiceRolls.new
    end
  end
end
