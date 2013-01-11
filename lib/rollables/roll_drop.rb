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

    def initialize(notation)
      matches = notation.match(/\A(([lh])([\d]*))\Z/i)
      @type = matches[2]
      @count = (matches[3].to_i > 1 ? matches[3].to_i : 1)
    end
    
    def initialize_copy(other)
      @type = other.type.clone unless other.type.nil?
      @count = other.count.clone unless other.count.nil?
    end
  end
end
