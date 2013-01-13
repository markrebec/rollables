module Rollables
  class DieRoll
    attr_reader :die, :modifier, :result, :timestamp
    alias_method :results, :result
    alias_method :total, :result
    
    def modifier=(modifier)
      @modifier << RollModifier.new(modifier)
    end

    def result
      if @modifier.nil? || @modifier.empty?
        @result.face
      else
        modified_result = @result.face
        @modifier.each { |modifier| modified_result = modifier.call(modified_result) }
        modified_result
      end
    end
    alias_method :total, :result
    alias_method :to_i, :result

    def to_s
      result.to_s
    end

    protected

    def initialize(die, *args, &block)
      params = {:modifier => nil}
      params.merge!(args[0]) if args.length > 0
      @die = die.clone
      @modifier = []
      @modifier << @die.modifier if @die.modifier?
      @modifier << RollModifier.new(params[:modifier]) unless params[:modifier].nil?
      @modifier << RollModifier.new(block) if block_given?
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
