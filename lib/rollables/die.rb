module Rollables
  class Die < Array
    attr_reader :modifier, :notation, :rolls
    
    def common?
      simple? && high == 6
    end

    def high
      numeric? ? sort.last : last
    end

    def low
      numeric? ? sort.first : first
    end

    def modifier=(modifier)
      if modifier.is_a?(RollModifier)
        @modifier = modifier
      elsif modifier.is_a?(Notations::Modifier)
        @modifier = RollModifier.new(modifier)
      else
        @modifier = RollModifier.new(Notations::Modifier.new(modifier))
      end
    end

    def modifier?
      !@modifier.nil?
    end
    
    def numeric?
      all? { |face| face.is_a?(Integer) }
    end

    def roll(&block)
      modifiers = []
      modifiers << @modifier if modifier?
      modifiers << block if block_given?
      @rolls << DieRoll.new(self, modifiers)
      @rolls.last
    end
    
    def sequential?
      numeric? && sort.each_cons(2).all? { |x,y| y == x + 1 }
    end
  
    def simple?
      sequential? && low == 1
    end

    def to_s
      @notation.to_s
    end
    
    protected

    def initialize(notation)
      initialize_notation notation
      raise "Cannot create single Die from '#{notation}'" if @notation.dice > 1
      raise "Cannot create Die with fewer than 2 faces" if @notation.faces.length < 2
      super @notation.faces.map { |face| DieFace.new(face) }
      @modifier = RollModifier.new(@notation.modifier.to_s)
      @rolls = DieRolls.new
    end

    def initialize_notation(notation)
      @notation = notation.is_a?(Notations::Die) ? notation : Notations::Die.new(notation)
    end
  end
end
