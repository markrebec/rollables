module Rollables
  class DieNotation
    attr_accessor :dice, :faces
    attr_reader :drop, :modifier

    def self.create(notation)
      if notation.stringy? && notation.to_s.match(/\s/)
        Dice.new(parse(notation))
      else
        notation = new(notation)
        (notation.dice > 1) ? Dice.new(notation) : Die.new(notation)
      end
    end

    def self.new(notation)
      return notation if notation.is_a?(self) || notation.is_a?(DieNotationArray)
      super
    end

    def self.parse(notation)
      if notation.is_a?(self) || notation.is_a?(DieNotationArray)
        notation
      elsif notation.is_a?(Array)
        DieNotationArray.new(notation.map { |n| parse(n) })
      elsif notation.stringy? && notation.to_s.match(/\s/)
        DieNotationArray.new(notation.to_s.split(/\s/).map { |n| new(n) })
      else
        new(notation)
      end
    end

    def common?
      simple? && high == 6
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

    def modifier?
      !@modifier.nil?
    end

    def modifier=(modstr)
      @modifier = Modifier.new(modstr)
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
      raise "Invalid DieNotation string #{notation}" unless @faces.length > 1
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
        Dice.new(self)
      else
        Die.new(self)
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
      #  return DieNotationArray.new(notation)
      #else
        @faces = notation.map { |face| (face.stringy? && face.to_s.to_i.to_s == face.to_s) ? face.to_i : face }
      #end
    end

    def parse_range(notation)
      parse_array(notation.to_a)
    end

    def parse_string(notation)
      matches = notation.to_s.match(/\A((\d+)d||d)?(\d+)((l||h)?(\d*))?([+\-\*\/][0-9+\-\*\/\(\)]*)?\Z/i)
      raise "Invalid DieNotation string #{notation}" if matches.nil?
      @dice = matches[2].to_i unless matches[2].nil? || matches[2].empty?
      @faces = matches[3].to_i.times.map { |face| face+1 }
      @drop = Drop.new(matches[5], matches[6])
      @modifier = Modifier.new(matches[7])
      raise "Cannot drop #{@drop.count} dice from #{@dice} dice" if !@drop.nil? && @drop.count >= @dice
    end

    class Drop
      attr_accessor :count
      attr_reader :type

      def self.new(type, count=nil)
        return nil if type.nil? || type.to_s.empty?
        super
      end

      def to_i
        @count
      end

      def to_s
        "#{@type}#{@count if @count > 1}"
      end

      protected

      def initialize(type, count=nil)
        @type = type.downcase
        @count = (count.nil? || count.to_i.zero?) ? 1 : count.to_i
      end
    end

    class Modifier
      attr_reader :raw
      
      def self.new(raw)
        return nil if raw.nil? || raw.to_s.empty?
        super
      end

      def to_s
        @raw.to_s
      end

      protected

      def initialize(raw)
        @raw = raw
      end
    end
  end
  
  class DieNotationArray < Array
    class << self
      def new(notations=[])
        notations = [notations] unless notations.is_a?(Array)
        notations.each { |notation| raise "Can only add Rollables::DieNotation and #{self.name} objects to #{self.name}" unless notation.is_a?(self) || notation.is_a?(DieNotation) }
        super
      end

      instance_eval do
        [:create, :parse].each do |meth|
          define_method(meth) { |*args,&block| DieNotation.send(meth, *args, &block) }
        end
      end
    end

    def <<(notation)
      raise "Can only add Rollables::DieNotation and #{self.class.name} objects to #{self.class.name}" unless notation.is_a?(self.class) || notation.is_a?(DieNotation)
      super
    end

    def is_die_notation?
      true
    end

    def method_missing(meth, *args, &block)
      if length > 0
        if meth.to_s[-1] == "?"
          return all? { |notation| notation.send(meth, *args, &block) }
        else
          return map { |notation| notation.send(meth, *args, &block) }
        end
      end
      super
    end

    def reduce
      reduced = self.class.new
      each do |notation|
        if notation.is_a?(self.class)
          reduced << notation.reduce
        elsif notation.modifier?
          reduced << notation.dup
        elsif reduced.reduce_include?(notation)
          reduced[reduced.reduce_index(notation)].merge(notation)
        else
          reduced << notation.dup
        end
      end
      reduced
    end

    def reduce!
      reduced = reduce
      clear
      reduced.each { |notation| self << notation }
      self
    end
    
    def reduce_include?(notation)
      map { |n| reduce_compare(n, notation) }.include?(true)
    end
    
    def reduce_index(notation)
      each { |n| return index(n) if reduce_compare(n, notation) }
    end
    
    def to_d
      Dice.new(self)
    end

    def to_s
      join(" ")
    end

    protected

    def reduce_compare(n1, n2)
      !n1.is_a?(self.class) &&
      !n2.is_a?(self.class) &&
      n2.modifier.nil? && 
      (n1.faces.sort == n2.faces.sort) &&
      ((n1.drop.nil? && n2.drop.nil?) || (n1.drop.type == n2.drop.type))
    end
  end
end
