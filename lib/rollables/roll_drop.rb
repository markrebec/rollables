module Rollables
  class RollDrop
    attr_reader :type, :count
    
    def to_i
      @count
    end

    def to_s
      "#{@type}#{@count if @count > 1}"
    end

    protected

    def initialize(type, count=1)
      @type = type
      @count = count.to_i > 1 ? count.to_i : 1
    end
    
    def initialize_copy(other)
      @type = other.type.clone unless other.type.nil?
      @count = other.count.clone unless other.count.nil?
    end
  end
end
