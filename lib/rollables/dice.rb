module Rollables
  class Dice
    attr_reader :dice, :rolls

    def add_dice(dice)
      @dice.add_dice(dice)
      self
    end
    alias_method :add_die, :add_dice

    def roll
      raise "A set of Dice must contain at least 1 Die" unless @dice.length > 0
      @rolls << DiceRoll.new(@dice)
      @rolls.last
    end

    def to_s
      combined_dice.collect { |faces,dcount| "#{dcount}#{faces}" }.join(",")
    end

    protected

    def combined_dice
      combined = {}
      @dice.each do |die|
        face_key = (die.simple?) ? "d#{die.faces.length}" : "d(#{die.faces.to_s})"
        combined[face_key] = 0 unless combined.has_key?(face_key)
        combined[face_key] += 1
      end
      combined
    end

    def initialize(*dice)
      @dice = DiceCollection.new(*dice)
      @rolls = DiceRolls.new
      self.class.instance_eval do
        [:high, :highest, :low, :lowest, :numeric?, :sequential?, :simple?].each do |m|
          define_method(m) { send(:dice).send(m) }
        end
      end
    end

    class DiceCollection < Array
      def add_dice(dice)
        assign_dice(dice)
        self
      end
      alias_method :add_die, :add_dice

      def high
        numeric? ? highs.sum : highs
      end

      def highest
        return highs.sort.last if numeric?
        sort do |x,y|
          result = x.high <=> y.high
          if result.nil?
            if (x.faces.length <=> y.faces.length) == 0
              x.high.is_a?(String) ? 1 : -1
            else
              x.faces.length <=> y.faces.length
            end
          else
            result
          end
        end.last.high
      end

      def highs
        collect &:high
      end

      def low
        numeric? ? lows.sum : lows
      end

      def lowest
        return lows.sort.first if numeric?
        sort do |x,y|
          result = x.low <=> y.low
          if result.nil?
            if (x.faces.length <=> y.faces.length) == 0
              x.low.is_a?(String) ? 1 : -1
            else
              x.faces.length <=> y.faces.length
            end
          else
            result
          end
        end.first.low
      end

      def lows
        collect &:low
      end

      def numeric?
        all? { |die| die.numeric? }
      end

      def sequential?
        all? { |die| die.sequential? }
      end

      def simple?
        all? { |die| die.simple? }
      end

      protected 

      def assign_dice(*dice)
        dice = [dice] unless dice.is_a? Array
        dice.each { |die| die.is_a?(Array) ? die.each { |d| assign_dice(d) } : assign_die(die) }
      end

      def assign_die(die)
        if die.is_a? Die
          self << die
        else
          smatch = die.to_s.match(/\A(\d+)[dD](\d+)\Z/)
          if smatch.nil?
            self << Die.new(die)
          else
            smatch[1].to_i.times do
              self << Die.new(smatch[2])
            end
          end
        end
      end

      def initialize(*dice)
        assign_dice(*dice)
      end
    end

    class DiceRoll
      attr_reader :rolls, :timestamp

      def to_s
        if @dice.numeric?
          "#{@rolls.collect { |roll| "#{roll.die.to_s}=#{roll.value.to_s}" }.join(" + ")} = #{value.sum}"
        else
          "#{@rolls.collect { |roll| "#{roll.die.to_s}=#{roll.value.to_s}" }.join(" + ")} = (#{value.join(",")})"
        end
      end

      def value
        @rolls.collect &:value
      end
      alias_method :result, :value

      protected
      
      def initialize(dice)
        @dice = dice
        @rolls = []
        @dice.each { |die| @rolls << die.roll }
        @timestamp = Time.now
      end
    end

    class DiceRolls < Array
      def to_s
        join(", ")
      end
    end
  end
end
