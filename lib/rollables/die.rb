module Rollables
  class Die < Array
    attr_reader :drop, :modifier, :notation, :rolls
    
    def common?
      simple? && high == 6
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
      #simple? ? @notation.to_s : "1d(#{join(",")})"
      @notation.to_s
    end
    
    protected

    def initialize(notation)
      initialize_notation notation
      raise "Cannot create single Die from '#{notation}'" if @notation.dice > 1
      raise "Cannot create Die with fewer than 2 faces" if @notation.faces.length < 2
      super @notation.faces.map { |face| DieFace.new(face) }
      @drop = 
      @rolls = DieRolls.new
    end

    def initialize_notation(notation)
      @notation = notation.is_a?(Notations::Die) ? notation : Notations::Die.new(notation)
    end
  end
end
