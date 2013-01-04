module Rollables
  class Die
    attr_reader :rolls, :faces

    def roll
      @rolls << DieRoll.new(self)
      @rolls.last
    end

    def to_s
      simple? ? "d#{@faces.length}" : "d(#{@faces.to_s})"
    end
    
    protected

    def initialize(faces)
      @faces = DieFaces.new(faces)
      @rolls = DieRolls.new
      self.class.instance_eval do
        [:common?, :high, :low, :numeric?, :sequential?, :simple?].each do |m|
          define_method(m) { send(:faces).send(m) }
        end
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

    class DieFaces < Array
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
      
      def sequential?
        numeric? && sort.each_cons(2).all? { |x,y| y == x + 1 }
      end
    
      def simple?
        sequential? && low == 1
      end

      def to_s
        join(",")
      end

      protected

      def d_to_a(faces)
        dmatch = faces.match(/\A(1[dD]||[dD])?(\d+)\Z/)
        raise "Cannot create Die from '#{faces}'" if dmatch.nil?
        dmatch[2].to_i.times.collect { |face| face+1 }
      end

      def initialize(faces)
        if faces.is_a?(String) || faces.is_a?(Integer) || faces.is_a?(Symbol)
          faces = d_to_a(faces.to_s)
        elsif faces.is_a?(Range)
          faces = faces.to_a
        elsif faces.is_a?(Array)
          #faces = faces.collect { |face| (face.is_a?(String) && face.to_i.to_s == face) ? face.to_i : face }
        else
          raise "Cannot create Die from '#{faces}'"
        end
        
        super faces.collect { |face| DieFace.new(face) }
        raise "A Die must have 2 or more faces" unless length > 1
      end
    end

    class DieRoll
      attr_reader :die, :timestamp, :value
      alias_method :result, :value
     
      def to_s
        @value.to_s
      end

      protected

      def initialize(die)
        @die = die
        roll
      end

      def roll
        @value = @die.faces.sample
        @timestamp = Time.now
      end
    end

    class DieRolls < Array
      def to_s
        join(",")
      end
    end
  end
end
