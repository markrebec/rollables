module Rollables
  class DiceRoll < Array
    attr_reader :dice, :drop, :modifier, :timestamp

    def dropped
      sort.to_a.slice(0,@drop.map { |drop| drop.type == 'l' ? drop.count : 0 }.sum).concat(sort.to_a.slice(-(@drop.map { |drop| drop.type == 'h' ? drop.count : 0 }.sum), (@drop.map { |drop| drop.type == 'h' ? drop.count : 0 }.sum)))
    end

    def inspect
      roll_results = collect(&:results)
      @drop.each { |drop| roll_results << drop } unless @drop.nil? || @drop.empty?
      @modifier.each { |modifier| roll_results << modifier } unless @modifier.nil? || @modifier.empty?
      roll_results
    end

    def kept
      sort.to_a.slice((@drop.map { |drop| drop.type == 'l' ? drop.count : 0 }.sum), (@dice.length - (@drop.map { |drop| drop.type == 'l' ? drop.count : 0 }.sum)) - (@drop.map { |drop| drop.type == 'h' ? drop.count : 0 }.sum))
    end

    def modifier=(modifier)
      @modifier << RollModifier.new(modifier)
    end

    def result
      if @modifier.nil? || @modifier.empty?
        @dice.numeric? ? kept.collect(&:result).flatten.sum : kept.collect(&:result).join(",")
      else
        modified_result = (@dice.numeric? ? kept.collect(&:result).flatten.sum : kept.collect(&:result))
        @modifier.each { |modifier| modified_result = modifier.call(modified_result) }
        @dice.numeric? ? modified_result : modified_result.join(",")
      end
    end
    alias_method :total, :result
    alias_method :to_i, :result

    def results
      roll_results = kept.collect(&:results)
      #@drop.each { |drop| roll_results << drop } unless @drop.nil? || @drop.empty?
      @modifier.each { |modifier| roll_results << modifier } unless @modifier.nil? || @modifier.empty?
      roll_results
    end

    def sort(&block)
      return super(&block) if block_given?
      super(&proc do |x,y|
        if x.result.class.name == y.result.class.name
          x.result <=> y.result
        elsif x.result.is_a?(Integer)
          -1
        elsif y.result.is_a?(Integer)
          1
        else
          0
        end
      end)
    end

    def to_s
      result.to_s
    end

    protected
    
    def initialize(dice, *args, &block)
      params = {:drop => nil, :modifier => nil}
      params.merge!(args[0]) if args.length > 0
      @dice = dice.clone
      @drop = @dice.drop
      params[:drop].scan(/(([lh])([\d]*))/i) { |drop| @drop << RollDrop.new(drop[0]) } unless params[:drop].nil?
      @modifier = []
      @modifier << @dice.modifier if @dice.modifier?
      @modifier << RollModifier.new(params[:modifier]) unless params[:modifier].nil?
      @modifier << RollModifier.new(block) if block_given?
      roll
    end

    def roll
      @dice.each { |die| self << die.roll }
      @timestamp = Time.now
    end
  end

  class DiceRolls < Array
    def to_s
      join(", ")
    end
  end
end
