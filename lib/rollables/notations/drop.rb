module Rollables
  module Notations
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
  end
end
