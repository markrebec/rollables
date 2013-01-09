require 'rollables'

describe Rollables::Dice do
  
  it "should be a valid instance of itself" do
    Rollables::Dice.new.should be_an_instance_of(Rollables::Dice)
  end

  it "should have a valid Die" do
    dice = Rollables::Dice.new(6)
    dice.first.should be_an_instance_of(Rollables::Die)
    dice.first.length.should == 6
  end
  
  it "should allow instantiation with integers" do
    dice = Rollables::Dice.new(6)
    dice.should be_an_instance_of(Rollables::Dice)
    dice.first.should be_an_instance_of(Rollables::Die)
    dice.first.length.should == 6
  end

  it "should allow instantiation with strings" do
    dice = Rollables::Dice.new("6")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.first.should be_an_instance_of(Rollables::Die)
    dice.first.length.should == 6
  end

  it "should allow instantiation with :d20 formatted symbols" do
    dice = Rollables::Dice.new(:d20)
    dice.should be_an_instance_of(Rollables::Dice)
    dice.first.should be_an_instance_of(Rollables::Die)
    dice.first.length.should == 20
  end

  it "should allow instantiation with 'd20' formatted strings" do
    dice = Rollables::Dice.new("d20")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.first.should be_an_instance_of(Rollables::Die)
    dice.first.length.should == 20
  end

  it "should allow instantiation with '1d20' formatted strings" do
    dice = Rollables::Dice.new("1d20")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.first.should be_an_instance_of(Rollables::Die)
    dice.first.length.should == 20
  end

  it "should allow instantiation of multiple dice" do
    dice = Rollables::Dice.new(20, 12, 6)
    dice.should be_an_instance_of(Rollables::Dice)
    dice[0].length.should == 20
    dice[1].length.should == 12
    dice[2].length.should == 6
  end
  
  it "should allow instantiation of multiple dice with arrays of dice" do
    dice = Rollables::Dice.new([Rollables::Die.new(20), Rollables::Die.new(12), Rollables::Die.new(6)])
    dice.should be_an_instance_of(Rollables::Dice)
    dice[0].length.should == 20
    dice[1].length.should == 12
    dice[2].length.should == 6
  end

  it "should allow instantiation of multiple dice with mixed formats" do
    dice = Rollables::Dice.new(20, "12", :d6, "d20", "1d6")
    dice.should be_an_instance_of(Rollables::Dice)
    dice[0].length.should == 20
    dice[1].length.should == 12
    dice[2].length.should == 6
    dice[3].length.should == 20
    dice[4].length.should == 6
  end

  it "should allow instantiation of multiple dice with '2d20' formatted strings" do
    dice = Rollables::Dice.new("2d20")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.length.should == 2
    dice.each do |die|
      die.should be_an_instance_of(Rollables::Die)
      die.length.should == 20
    end
  end

  it "should allow adding a single die" do
    Rollables::Dice.new.add_die(:d6).length.should == 1
    Rollables::Dice.new(20).add_die(:d6).length.should == 2
  end

  it "should allow adding multiple dice" do
    Rollables::Dice.new.add_dice(:d6, "2d8").length.should == 3
    Rollables::Dice.new(20).add_dice(:d6, "2d8").length.should == 4
  end

  it "should allow chaining the addition of dice" do
    Rollables::Dice.new.add_dice(6, 12).add_die(:d8).add_dice("2d20").length.should == 5
  end

  it "should be numeric if all die have all numeric faces" do
    Rollables::Dice.new(:d6, 1..8, 20).numeric?.should be_true
  end

  it "should not be numeric if any die have any non-numeric faces" do
    Rollables::Dice.new(:d6, Rollables::Die.new(["a","b","c"]), 20).numeric?.should be_false
  end

  it "should be sequential if all die are all numeric and sequential" do
    Rollables::Dice.new(6, 12, Rollables::Die.new([2,5,3,4])).sequential?.should be_true
  end

  it "should not be sequential if any die are non-numeric or non-sequential" do
    Rollables::Dice.new(6, Rollables::Die.new([1,2,3,4,"a"])).sequential?.should be_false
    Rollables::Dice.new(6, :d20, Rollables::Die.new([2,5,4])).sequential?.should be_false
  end

  it "should be simple if all die are all simple" do
    Rollables::Dice.new(6, 12, Rollables::Die.new([1,2,5,3,4])).simple?.should be_true
  end

  it "should not be simple if any die are not simple" do
    Rollables::Dice.new(6, Rollables::Die.new([1,2,3,4,"a"])).simple?.should be_false
    Rollables::Dice.new(6, :d20, Rollables::Die.new([2,3,4])).simple?.should be_false
  end
  
  it "should return the correct value(s) for high" do
    Rollables::Dice.new(8, 20, 6).high.should == 34
    Rollables::Dice.new(20, Rollables::Die.new([0,5,10])).high.should == 30
    Rollables::Dice.new(6, 20, Rollables::Die.new(["a",2,3])).high.should == [6,20,3]
  end
  
  it "should return the correct value(s) for low" do
    Rollables::Dice.new(8, 20, 6).low.should == 3
    Rollables::Dice.new(20, Rollables::Die.new([0,5,10])).low.should == 1
    Rollables::Dice.new(6, 20, Rollables::Die.new(["a",2,3])).low.should == [1,1,"a"]
  end
  
  it "should return a properly formatted string from to_s" do
    Rollables::Dice.new(6, :d6, 12).to_s.should == "2d6 1d12"
    Rollables::Dice.new(1..6, "1d6").to_s.should == "2d6"
    Rollables::Dice.new("2d8", Rollables::Die.new(["a","b","c"]), Rollables::Die.new(["a","b","c"])).to_s.should == "2d8 2d3(a,b,c)"
  end
  
  it "should be able to be rolled" do
    Rollables::Dice.new(6, :d12).roll.should be_an_instance_of(Rollables::DiceRoll)
  end
  
  it "should be able to be rolled with a modifier" do
    dice = Rollables::Dice.new(Rollables::Die.new(6), Rollables::Die.new(:d12))
    20.times do
      roll = dice.roll { |result| result + 10 }
      roll.result.should be_between(12, 28)
    end
    20.times do
      roll = dice.roll { |result| Rollables::RollModifier.new("+2").call(result) }
      roll.result.should be_between(4, 20)
    end
  end
end

describe Rollables::DiceRoll do
  it "should return a properly formatted string from to_s" do
    [Rollables::Dice.new(:d8, Rollables::Die.new([1,4,3,5,2])), Rollables::Dice.new(Rollables::Die.new(["a","b","c"]), 6), Rollables::Dice.new(1..12, Rollables::Die.new([2,5,1,9,8]))].each do |dice|
      roll = dice.roll
      if (dice.numeric?)
        roll.to_s.should == "(#{roll.collect { |r| r.to_s }.join(" + ")}) = (#{roll.collect(&:result).join("+")} = #{roll.result})"
      else
        roll.to_s.should == "(#{roll.collect { |r| r.to_s }.join(" + ")}) = (#{roll.join(",")})"
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
