module Rollables
  module Notations
    class Die
      attr_accessor :dice, :faces
      attr_reader :drop, :modifier

      def self.create(notation)
        if notation.stringy? && notation.to_s.match(/\s/)
          ::Rollables::Dice.new(parse(notation))
        else
          notation = new(notation)
          (notation.dice > 1) ? Rollables::Dice.new(notation) : Rollables::Die.new(notation)
        end
      end

      def self.new(notation)
        return notation if notation.is_a?(self) || notation.is_a?(Dice)
        super
      end

      def self.parse(notation)
        if notation.is_a?(self) || notation.is_a?(Dice)
          notation
        elsif notation.is_a?(Array)
          Dice.new(notation.map { |n| parse(n) })
        elsif notation.stringy? && notation.to_s.match(/\s/)
          Dice.new(notation.to_s.split(/\s/).map { |n| new(n) })
        else
          new(notation)
        end
      end

      def common?
        simple? && high == 6
      end

      def drop=(drop)
        raise "Cannot coerce #{drop.class.name} into Drop notation" unless drop.is_a?(Drop) || drop.nil?
        @drop = drop
      end

      def drop?
        !@drop.nil?
      end

      def high
        numeric? ? @faces.sort.last : @faces.last
      end

      def is_die_notation?
        true
      end

      def low
        numeric? ? @faces.sort.first : @faces.first
      end
      
      def merge(notation)
        notation = [notation] unless notation.is_a?(Array)
        notation.each do |n|
          @dice += n.dice
          (drop? ? @drop.count += n.drop.count : @drop = n.drop.dup) if n.drop?
        end
        self
      end

      def modifier=(modifier)
        raise "Cannot coerce #{modifier.class.name} into Modifier notation" unless modifier.is_a?(Modifier) || modifier.nil?
        @modifier = modifier
      end

      def modifier?
        !@modifier.nil?
      end

      def numeric?
        @faces.all? { |face| face.is_a?(Integer) }
      end

      def parse(notation=nil)
        raise "Cannont parse empty notation" if notation.nil?
        if notation.stringy?
          raise "Cannot parse empty notation string" if notation.to_s.empty?
          parse_string(notation)
        elsif notation.is_a?(Range)
          parse_range(notation)
        elsif notation.is_a?(Array)
          parse_array(notation)
        else
          raise "Unsupported notation type '#{notation.class.name}'"
        end
        raise "Invalid Die notation string #{notation}" unless @faces.length > 1
        self
      end

      def reset
        @dice = 1
        @faces = []
        @drop = nil
        @modifier = nil
        self
      end

      def sequential?
        numeric? && @faces.sort.each_cons(2).all? { |x,y| y == x + 1 }
      end

      def simple?
        sequential? && low == 1
      end

      def singular
        self.class.new("1d#{@faces.length}")
      end

      def singular?
        @dice == 1
      end

      def to_d
        if @dice > 1
          ::Rollables::Dice.new(self)
        else
          ::Rollables::Die.new(self)
        end
      end

      def to_s
        @faces.length > 0 ? "#{@dice}d#{@faces.length}#{"(#{@faces.join(",")})" unless simple?}#{@drop}#{@modifier}" : ""
      end

      protected

      def initialize(notation=nil)
        reset
        parse notation
      end

      def initialize_copy(other)
        @drop = other.drop.dup if other.drop?
        @modifier = other.modifier.dup if other.modifier?
      end

      def parse_array(notation)
        #if notation.all? { |n| n.is_die_notation? }
        #  return Dice.new(notation)
        #else
          @faces = notation.map { |face| (face.stringy? && face.to_s.to_i.to_s == face.to_s) ? face.to_i : face }
        #end
      end

      def parse_range(notation)
        parse_array(notation.to_a)
      end

      def parse_string(notation)
        matches = notation.to_s.match(/\A((\d+)d||d)?(\d+)((l||h)?(\d*))?([+\-\*\/][0-9+\-\*\/\(\)]*)?\Z/i)
        raise "Invalid Die notation string #{notation}" if matches.nil?
        @dice = matches[2].to_i unless matches[2].nil? || matches[2].empty?
        @faces = matches[3].to_i.times.map { |face| face+1 }
        @drop = Drop.new(matches[5], matches[6])
        @modifier = Modifier.new(matches[7])
        raise "Cannot drop #{@drop.count} dice from #{@dice} dice" if !@drop.nil? && @drop.count >= @dice
      end
    end
  end
end
