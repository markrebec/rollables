module Rollables
  module Notations
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
end
