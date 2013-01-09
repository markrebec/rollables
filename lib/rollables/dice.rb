module Rollables
  class Dice < Array
    attr_reader :drop, :modifier, :rolls

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

    def modifier=(modifier)
      if modifier.is_a?(RollModifier)
        @modifier = modifier
      elsif modifier.is_a?(Notations::Modifier)
        @modifier = RollModifier.new(modifier)
      else
        @modifier = RollModifier.new(Notations::Modifier.new(modifier))
      end
    end

    def modifier?
      !@modifier.nil?
    end
    
    def notation
      return Notations::Dice.new(map { |die| die.notation })
    end

    def numeric?
      all? { |die| die.numeric? }
    end

    def roll(&block)
      raise "A set of Dice must contain at least 1 Die" unless length > 0
      modifiers = []
      modifiers << @modifier if modifier?
      modifiers << block if block_given?
      @rolls << DiceRoll.new(self, modifiers)
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
          assign_dice_notation(die)
        elsif die.is_a?(Array) && die.all? { |d| d.is_a?(Die) || d.is_a?(Dice) }
          die.each { |d| self << d }
        else
          assign_dice(Notations::Die.parse(die))
        end
      end
    end
    
    def assign_die_notation(notation)
      if notation.drop? || notation.modifier?
        if (notation.dice > 1) 
          dice = self.class.new(notation.dice.times.map { Die.new(notation.singular) })
          dice.modifier = RollModifier.new(notation.modifier.to_s)
          # TODO add drop
          self << dice
        else
          self << Die.new(notation)
        end
      else
        notation.dice > 1 ? notation.dice.times.map { self << Die.new(notation.singular) } : self << Die.new(notation)
      end
    end
    
    def assign_dice_notation(notation)
      dice = self.class.new
      notation.each do |n|
        dice.add_dice(n)
      end
      dice.modifier = RollModifier.new(notation.modifier.to_s)
      # TODO add drop
      self << dice
    end

    def initialize(*dice)
      assign_dice(*dice)
      @rolls = DiceRolls.new
    end
  end
end
