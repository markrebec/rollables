module Rollables
  class Die < Array
    attr_reader :rolls, :notation
    
    def common?
      length == 6 && simple?
    end

    def high
      numeric? ? sort.last : last
    end

    def low
      numeric? ? sort.first : first
    end
    
    def numeric?
      all? { |face| face.is_a?(Integer) }
    end

    def roll(&block)
      @rolls << DieRoll.new(self, &block)
      @rolls.last
    end
    
    def sequential?
      numeric? && sort.each_cons(2).all? { |x,y| y == x + 1 }
    end
  
    def simple?
      sequential? && low == 1
    end

    def to_s
      simple? ? @notation.to_s : "1d(#{join(",")})"
    end
    
    protected

    def initialize(notation)
      initialize_notation notation
      raise "Cannot create single Die from '#{notation}'" if @notation.dice > 1
      raise "Cannot create Die with fewer than 2 faces" if @notation.faces.length < 2
      super @notation.faces.map { |face| DieFace.new(face) }
      @rolls = DieRolls.new
    end

    def initialize_notation(notation)
      @notation = notation.is_a?(DieNotation) ? notation : DieNotation.new(notation)
    end
  end

  class DieFace
    def self.new(face)
      face = face.to_i if face.is_a?(String) && face.to_i.to_s == face

      face.instance_eval do
        # shared methods go here
        if self.is_a?(Integer)
          # integer methods go here
        elsif self.is_a?(String)
          # string methods go here
        #elsif self.is_a?(Symbol)
          # symbol methods go here
        else
          raise "Unsupported DieFace type `#{face.class.name}`"
        end
      end
      
      face
    end
  end

  class DieRoll
    attr_accessor :modifier
    attr_reader :die, :timestamp
   
    def result
      @modifier.nil? ? @result : @modifier.call(@result)
    end
    alias_method :value, :result
    
    def to_s
      result.to_s
    end

    protected

    def initialize(die, &block)
      # TODO pull out the copy of Die once DiceRoll doesn't need it anymore
      @die = die
      @modifier = block if block_given?
      roll
    end

    def roll
      @result = @die.sample
      @timestamp = Time.now
    end
  end

  class DieRolls < Array
    def to_s
      join(",")
    end
  end
end
