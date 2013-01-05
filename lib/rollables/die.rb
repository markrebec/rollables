module Rollables
  class Die < Array
    attr_reader :rolls
    
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
      simple? ? "d#{length}" : "d(#{join(",")})"
    end
    
    protected
    
    def d_to_a(faces)
      dmatch = faces.match(/\A(1[dD]||[dD])?(\d+)\Z/)
      raise "Cannot create Die from '#{faces}'" if dmatch.nil?
      dmatch[2].to_i.times.collect { |face| face+1 }
    end

    def initialize(faces)
      super(parse_faces(faces).map { |face| DieFace.new(face) })
      @rolls = DieRolls.new
    end

    def parse_faces(faces)
      if faces.is_a?(String) || faces.is_a?(Integer) || faces.is_a?(Symbol)
        faces = d_to_a(faces.to_s)
      elsif faces.is_a?(Range)
        faces = faces.to_a
      elsif faces.is_a?(Array)
      else
        raise "Cannot create Die from '#{faces}'"
      end
      
      raise "A Die must have 2 or more faces" unless faces.length > 1
      faces
    end
  end

  class DieFace
    def self.new(face)
      face = face.to_i if face.is_a?(String) && face.to_i.to_s == face

      face.instance_eval do
        # shared methods go here
        if self.is_a?(String)
          # string methods go here
        elsif self.is_a?(Integer)
          # integer methods go here
        else
          raise "Unsupported DieFace type `#{face.class.name}`"
        end
      end
      
      face
    end
  end

  class DieNotation; end

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
