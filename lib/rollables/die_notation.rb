module Rollables
  class DieNotation
    attr_accessor :dice, :drop, :faces, :modifier

    def self.parse(notation)
      self.new(notation)
    end

    def self.create(notation)
      if notation.stringy? && notation.to_s.match(/\s/)
        Dice.new(notation.split(/\s/))
      else
        notation = self.new(notation)
        (notation.dice > 1) ? Dice.new(notation.to_s) : Die.new(notation)
      end
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
      @faces.length > 0 ? "#{@dice}d#{@faces.length}#{@drop}#{@modifier}" : ""
    end

    protected

    def initialize(notation=nil)
      reset
      parse notation
    end

    def parse_array(notation)
      @faces = notation
    end

    def parse_range(notation)
      parse_array(notation.to_a)
    end

    def parse_string(notation)
      matches = notation.to_s.match(/\A((\d+)d||d)?(\d+)(l||h)?([0-9+\-*\/\(\)]*)?\Z/i)
      raise "Invalid DieNotation string" if matches.nil?
      @dice = matches[2].to_i unless matches[2].nil? || matches[2].empty?
      @faces = matches[3].to_i.times.map { |face| face+1 }
      @drop = matches[4].upcase
      @modifier = matches[5]
    end
  end
end
