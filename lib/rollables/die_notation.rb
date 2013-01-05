module Rollables
  class DieNotation
    attr_accessor :dice, :drop, :faces, :modifier

    def self.create(notation)
      if notation.stringy? && notation.to_s.match(/\s/)
        Dice.new(notation.split(/\s/))
      else
        notation = self.new(notation)
        (notation.dice > 1) ? Dice.new(notation) : Die.new(notation)
      end
    end

    def self.parse(notation)
      self.new(notation)
    end

    def common?
      simple? && high == 6
    end

    def high
      numeric? ? @faces.sort.last : @faces.last
    end

    def low
      numeric? ? @faces.sort.first : @faces.first
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
      raise "Invalid DieNotation string" unless @faces.length > 1
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

    def to_d
      if @dice > 1
        Dice.new(self.to_s.split(/\s/))
      else
        Die.new(self)
      end
    end

    def to_s
      @faces.length > 0 ? "#{@dice}d#{@faces.length}#{@drop}#{@modifier}#{"(#{@faces.join(",")})" unless simple?}" : ""
    end

    protected

    def initialize(notation=nil)
      reset
      parse notation
    end

    def parse_array(notation)
      @faces = notation.map { |face| (face.stringy? && face.to_s.to_i.to_s == face.to_s) ? face.to_i : face }
    end

    def parse_range(notation)
      parse_array(notation.to_a)
    end

    def parse_string(notation)
      matches = notation.to_s.match(/\A((\d+)d||d)?(\d+)(l||h)?([0-9+\-*\/\(\)]*)?\Z/i)
      raise "Invalid DieNotation string" if matches.nil?
      @dice = matches[2].to_i unless matches[2].nil? || matches[2].empty?
      @faces = matches[3].to_i.times.map { |face| face+1 }
      @drop = matches[4].upcase unless matches[4].nil? || matches[4].empty?
      @modifier = matches[5] unless matches[5].nil? || matches[5].empty?
    end
  end
end
