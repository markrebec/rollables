module Rollables
  class Dice < Array
    attr_reader :drop, :modifier, :rolls
    
    def self.new(*dice)
      return dice if dice.is_a?(self.class)
      super
    end
    
    # Overrides to ensure only Die/Dice are added # TODO DRY this up, and maybe just alias to add_dice?
    def <<(dice)
      raise "Only Die and Dice objects may be added to an existing Dice object" unless dice.is_a?(self.class) || dice.is_a?(Die)
      super
    end
    def push(dice)
      raise "Only Die and Dice objects may be added to an existing Dice object" unless dice.is_a?(self.class) || dice.is_a?(Die)
      super
    end
    def unshift(dice)
      raise "Only Die and Dice objects may be added to an existing Dice object" unless dice.is_a?(self.class) || dice.is_a?(Die)
      super
    end

    def add_dice(dice)
      if dice.is_a?(self.class) || dice.is_a?(Die)
        self << dice
      elsif dice.is_a?(Array)
        dice.each do |die|
          if die.is_a?(self.class) || die.is_a?(Die)
            self << die
          else
            parse(die)
          end
        end
      else
        parse(dice)
      end
      self
    end
    alias_method :add_die, :add_dice

    def common?
      all? { |die| die.common? }
    end

    def drop=(drop)
      @drop << drop.is_a?(RollDrop) ? drop : RollDrop.new(drop)
    end

    def drop?
      @drop.length > 0
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
      modifier.is_a?(RollModifier) ? @modifier = modifier : @modifier = RollModifier.new(modifier)
    end

    def modifier?
      !@modifier.nil?
    end
   
    def reduce
      reduced = {}
      each do |die|
        if die.is_a?(self.class)
          if die.drop? || die.modifier?
            reduced[die.notation] = 0 unless reduced.has_key?(die.notation)
            reduced[die.notation] += 1
          else
            die.reduce.each do |notation,count|
              reduced[notation] = 0 unless reduced.has_key?(notation)
              reduced[notation] += 1
            end
          end
        elsif die.is_a?(Die)
          notation = die.notation.gsub(/\A\d+/, "")
          reduced[notation] = 0 unless reduced.has_key?(notation)
          reduced[notation] += 1
        end
      end
      reduced
    end

    def notation
      notation_string = reduce.map { |notation,dice| notation.match(/[lh+\-*\/].*\Z/) ? dice.times.map { notation }.join(", ") : "#{dice}#{notation}" }.join(" + ")
      notation_string = "(#{notation_string})" if reduce.length > 1 && (drop? || modifier?)
      notation_string.concat("#{@drop.map(&:to_s).join}#{@modifier.to_s}")
    end

    def numeric?
      all? { |die| die.numeric? }
    end
    
    def roll(*args, &block)
      raise "A set of Dice must contain at least 1 Die" unless length > 0
      @rolls << DiceRoll.new(self, *args, &block)
      @rolls.last
    end

    def sequential?
      all? { |die| die.sequential? }
    end

    def simple?
      all? { |die| die.simple? }
    end

    def to_s
      notation
    end

    protected
    
    def encapsulate
      dice = self.clone
      reset
      self << dice
    end

    def initialize(*dice)
      dice = [dice] unless dice.is_a?(Array) && !dice.is_a?(Die) && !dice.is_a?(self.class)
      reset
      dice.each { |die| add_dice(die) }
    end

    def initialize_copy(other)
      super
      @drop = other.drop.clone
      @modifier = other.modifier.clone unless other.modifier.nil?
      @rolls = other.rolls.clone
    end

    def parse(notation)
      if notation.stringy?
        notation.to_s.match(/\s/) ? notation.to_s.split(/\s/).each { |n| parse_string(n) } : parse_string(notation)
      elsif notation.is_a?(Range)
        parse_range(notation)
      elsif notation.is_a?(Array)
        parse_array(notation)
      elsif !notation.nil?
        raise "Unsupported notation type #{notation.class.name}."
      end
    end

    def parse_array(notations)
      raise "Cannot parse empty notation." if notations.empty?
      encapsulate if drop? || modifier?
      notations.each do |notation|
        self << ((notation.is_a?(self.class) || notation.is_a?(Die)) ? notation : Die.new(notation))
      end
    end

    def parse_range(notation)
      self << Die.new(notation)
    end

    def parse_string(notation)
      raise "Cannot parse empty notation string." if notation.to_s.empty?
      matches = notation.to_s.match(/\A((\d+)d||d)?(\d+)([[lh][\d]*]*)?([+\-\*\/][0-9+\-\*\/\(\)]*)?\Z/i)
      raise "Invalid notation string #{notation}." if matches.nil?
      
      dice_count = matches[2].nil? ? 1 : matches[2].to_i
      dice_drop = []
      unless matches[4].nil? || matches[4].empty?
        matches[4].scan(/(([lh])([\d]*))/i) { |drop| dice_drop << RollDrop.new(drop[0]) }#drop[1], drop[2]) }
      end
      dice_modifier = RollModifier.new(matches[5])
      raise "Cannot drop #{dice_drop.map(&:count).sum} dice from #{dice_count} dice" if !dice_drop.empty? && dice_drop.collect(&:count).sum >= dice_count
      
      encapsulate if drop? || modifier?
      
      if !dice_drop.empty? || !dice_modifier.nil?
        dice = self.class.new
        dice_count.times do |d|
          dice << Die.new(matches[3].to_i)
        end
        dice.modifier = dice_modifier
        dice_drop.each { |drop| dice.drop << drop }
        if empty?
          @drop = dice.drop.clone
          @modifier = dice.modifier.clone unless dice.modifier.nil?
          dice.each { |die| self << die }
        else
          self << dice
        end
      elsif dice_count > 1
        dice_count.times do |d|
          self << Die.new(matches[3].to_i)
        end
      else
        die = Die.new(matches[3].to_i)
        self << die
      end
    end

    def reset
      clear
      @modifier = nil
      @drop = []
      @rolls = DiceRolls.new
    end
  end
end
