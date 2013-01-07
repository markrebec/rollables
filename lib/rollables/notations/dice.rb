module Rollables
  module Notations
    class Dice < Array
      attr_reader :drop, :modifier

      class << self
        def new(notations=[])
          notations = [notations] unless notations.is_a?(Array)
          notations.each { |notation| raise "Can only add Rollables::Notations::Die and #{self.name} objects to #{self.name}" unless notation.is_a?(self) || notation.is_a?(Die) }
          super
        end

        instance_eval do
          [:create, :parse].each do |meth|
            define_method(meth) { |*args,&block| Die.send(meth, *args, &block) }
          end
        end
      end

      def <<(notation)
        raise "Can only add Rollables::Notations::Die and #{self.class.name} objects to #{self.class.name}" unless notation.is_a?(self.class) || notation.is_a?(Die)
        super
      end

      def drop=(drop)
        raise "Cannot coerce #{drop.class.name} into Drop notation" unless drop.is_a?(Drop) || drop.nil?
        @drop = drop
      end

      def drop?
        !@drop.nil?
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

      def modifier=(modifier)
        raise "Cannot coerce #{modifier.class.name} into Modifier notation" unless modifier.is_a?(Modifier) || modifier.nil?
        @modifier = modifier
      end

      def modifier?
        !@modifier.nil?
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
        reduced.drop = @drop
        reduced.modifier = @modifier
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
        ::Rollables::Dice.new(self)
      end

      def to_s
        if length > 1 && (modifier? || drop?)
          "(#{join(" ")})#{@drop.to_s}#{@modifier.to_s}"
        elsif modifier? || drop?
          "#{join(" ")}#{@drop.to_s}#{@modifier.to_s}"
        else
          join(" ")
        end
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
end
