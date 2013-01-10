require 'rollables'

describe Rollables::DiceRoll do
  it "should return a properly formatted string from to_s" do
    [Rollables::Dice.new(:d8, Rollables::Die.new([1,4,3,5,2])), Rollables::Dice.new(Rollables::Die.new(["a","b","c"]), 6), Rollables::Dice.new(1..12, Rollables::Die.new([2,5,1,9,8]))].each do |dice|
      roll = dice.roll
      if (dice.numeric?)
        roll.to_s.should == roll.result.to_s
      else
        roll.to_s.should == roll.results.join(",")
      end
    end
  end
  
  it "should return all the right face values for die rolls" do
    dice = Rollables::Dice.new("3d6")
    roll = dice.roll
    roll.result.should == roll.collect(&:result).sum
  end
end

describe Rollables::DiceRolls do
  it "should return a properly formatted string from to_s" do
    [Rollables::Dice.new(:d8, Rollables::Die.new([1,4,3,5,2])), Rollables::Dice.new(Rollables::Die.new(["a","b","c"]), 6), Rollables::Dice.new(1..12, Rollables::Die.new([2,5,1,9,8]))].each do |dice|
      5.times { dice.roll }
      dice.rolls.to_s.should == dice.rolls.join(", ")
    end
  end
end
