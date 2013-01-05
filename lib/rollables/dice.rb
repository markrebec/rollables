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
      notation_obj.collect { |notation,die_count| "#{die_count}#{notation}" }.join(",")
    end

    protected

    def assign_dice(*dice)
      dice = [dice] unless dice.is_a?(Array) && !dice.is_a?(Die)
      dice.each { |die| (die.is_a?(Array) && !die.is_a?(Die)) ? die.each { |d| assign_dice(d) } : assign_die(die) }
    end

    def assign_die(die)
      if die.is_a? Die
        self << die
      else
        parse_notation_str(die).each { |d| self << d }
      end
    end

    def notation_obj
      combined = {}
      each do |die|
        face_key = (die.simple?) ? "d#{die.length}" : "d(#{die.join(",")})"
        combined[face_key] = 0 unless combined.has_key?(face_key)
        combined[face_key] += 1
      end
      combined
    end

    def parse_notation_str(diestr)
      dmatch = diestr.to_s.match(/\A(\d+)[dD](\d+)\Z/)
      if dmatch.nil?
        return [Die.new(diestr)]
      else
        return dmatch[1].to_i.times.collect { Die.new(dmatch[2]) }
      end
    end

    def initialize(*dice)
      assign_dice(*dice)
      @rolls = DiceRolls.new
    end
  end

  class DiceNotation; end

  class DiceRoll
    attr_accessor :modifier
    attr_reader :results, :timestamp

    def result
      # TODO add flag to control whether modifier block is passed through or added at the end
      @modifier.nil? ? @results.collect(&:value) : @modifier.call(@results.collect(&:value))
    end
    alias_method :value, :result

    def to_s
      # TODO rework this so it doesn't require DieRoll to have a copy of Die
      if @dice.numeric?
        "#{@results.collect { |roll| "#{roll.die.to_s}=#{roll.result.to_s}" }.join(" + ")} = #{result.sum}"
      else
        "#{@results.collect { |roll| "#{roll.die.to_s}=#{roll.result.to_s}" }.join(" + ")} = (#{result.join(",")})"
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
      # TODO add flag to control whether modifier block is passed through or added at the end
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
