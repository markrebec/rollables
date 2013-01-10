require 'rollables'

describe Rollables::DieRoll do
  it "should roll on init" do
    die = Rollables::Die.new(:d6)
    roll = die.roll
    roll.result.should_not be_nil
    roll.timestamp.should_not be_nil
  end

  it "should return a properly formatted string from to_s" do
    [Rollables::Die.new(6), Rollables::Die.new(["a","b","c","hello"])].each do |die|
      20.times do
        roll = die.roll
        roll.to_s.should == roll.result.to_s
      end
    end
  end
end

describe Rollables::DieRolls do
  it "should return a properly formatted string from to_s" do
    [Rollables::Die.new(6), Rollables::Die.new(["z","y","x"])].each do |die|
      5.times { die.roll }
      die.rolls.to_s.should == die.rolls.collect { |roll| roll.to_s }.join(",")
    end
  end
end
