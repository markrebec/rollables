module Rollables
  class Die < Array
    attr_reader :modifier, :rolls
    
    def self.new(die)
      return die if die.is_a?(self.class) || die.is_a?(Dice)
      super
    end

    # Overrides to ensure only DieFaces are added # TODO DRY this up
    def <<(face)
      super(face.is_a?(DieFace) ? face : DieFace.new(face))
    end
    def push(face)
      super(face.is_a?(DieFace) ? face : DieFace.new(face))
    end
    def unshift(face)
      super(face.is_a?(DieFace) ? face : DieFace.new(face))
    end

    def common?
      simple? && high.face == 6
    end

    def high
      numeric? ? sort.last : last
    end

    def low
      numeric? ? sort.first : first
    end

    def modifier=(modifier)
      modifier.is_a?(RollModifier) ? @modifier = modifier : @modifier = RollModifier.new(modifier)
    end

    def modifier?
      !@modifier.nil?
    end

    def notation
      "1d#{simple? ? length : "#{length}(#{join(",")})"}#{@modifier.to_s}"
    end

    def numeric?
      all? { |face| face.face.is_a?(Integer) }
    end

    def roll(*args, &block)
      @rolls << DieRoll.new(self, *args, &block)
      @rolls.last
    end
    
    def sequential?
      numeric? && sort.each_cons(2).all? { |x,y| y.face == x.face + 1 }
    end
  
    def simple?
      sequential? && low.face == 1
    end

    def sort(&block)
      return super(&block) if block_given?
      super(&proc { |x,y| (x.face.is_a?(Integer) && y.face.is_a?(Integer)) ? x.face <=> y.face : 0 })
    end

    def to_s
      notation
    end
    
    protected

    def initialize(notation)
      parse(notation)
      @rolls = DieRolls.new
    end

    def initialize_copy(other)
      super
      @rolls = other.rolls.clone
    end

    def parse(notation)
      if notation.stringy?
        parse_string(notation)
      elsif notation.is_a?(Range)
        parse_range(notation)
      elsif notation.is_a?(Array)
        parse_array(notation)
      else
        raise "Unsupported notation type #{notation.class.name}."
      end
      raise "Invalid #{self.class.name} notation #{notation.to_s}. A Die must have at least 2 faces." unless length > 1
    end

    def parse_array(notation)
      raise "Cannot parse empty notation." if notation.empty?
      notation.each { |face| self << DieFace.new((face.stringy? && face.to_s.to_i.to_s == face.to_s) ? face.to_i : face) }
    end

    def parse_range(notation)
      parse_array(notation.to_a)
    end

    def parse_string(notation)
      raise "Cannot parse empty notation string." if notation.to_s.empty?
      matches = notation.to_s.match(/\A((\d+)d||d)?(\d+)([+\-\*\/][0-9+\-\*\/\(\)]*)?\Z/i)
      raise "Invalid notation string #{notation}." if matches.nil?
      raise "Cannot create single Die from #{notation}." unless matches[2].nil? || matches[2].empty? || matches[2].to_i == 1
      matches[3].to_i.times.map { |face| self << DieFace.new(face+1) }
      @modifier = RollModifier.new(matches[4])
    end
  end
end
