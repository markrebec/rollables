require 'rollables'

describe Rollables::Dice do
  
  it "should be a valid instance of itself" do
    Rollables::Dice.new.should be_an_instance_of(Rollables::Dice)
  end

  it "should have a valid Die" do
    dice = Rollables::Dice.new(6)
    dice.dice.first.should be_an_instance_of(Rollables::Die)
    dice.dice.first.faces.length.should == 6
  end
  
  it "should allow instantiation with integers" do
    dice = Rollables::Dice.new(6)
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice.first.should be_an_instance_of(Rollables::Die)
    dice.dice.first.faces.length.should == 6
  end

  it "should allow instantiation with strings" do
    dice = Rollables::Dice.new("6")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice.first.should be_an_instance_of(Rollables::Die)
    dice.dice.first.faces.length.should == 6
  end

  it "should allow instantiation with :d20 formatted symbols" do
    dice = Rollables::Dice.new(:d20)
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice.first.should be_an_instance_of(Rollables::Die)
    dice.dice.first.faces.length.should == 20
  end

  it "should allow instantiation with 'd20' formatted strings" do
    dice = Rollables::Dice.new("d20")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice.first.should be_an_instance_of(Rollables::Die)
    dice.dice.first.faces.length.should == 20
  end

  it "should allow instantiation with '1d20' formatted strings" do
    dice = Rollables::Dice.new("1d20")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice.first.should be_an_instance_of(Rollables::Die)
    dice.dice.first.faces.length.should == 20
  end

  it "should allow instantiation of multiple dice" do
    dice = Rollables::Dice.new(20, 12, 6)
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice[0].faces.length.should == 20
    dice.dice[1].faces.length.should == 12
    dice.dice[2].faces.length.should == 6
  end
  
  it "should allow instantiation of multiple dice with arrays" do
    dice = Rollables::Dice.new([20, 12, 6])
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice[0].faces.length.should == 20
    dice.dice[1].faces.length.should == 12
    dice.dice[2].faces.length.should == 6
  end

  it "should allow instantiation of multiple dice with mixed formats" do
    dice = Rollables::Dice.new(20, "12", :d6, "d20", "1d6")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice[0].faces.length.should == 20
    dice.dice[1].faces.length.should == 12
    dice.dice[2].faces.length.should == 6
    dice.dice[3].faces.length.should == 20
    dice.dice[4].faces.length.should == 6
  end

  it "should allow instantiation of multiple dice with '2d20' formatted strings" do
    dice = Rollables::Dice.new("2d20")
    dice.should be_an_instance_of(Rollables::Dice)
    dice.dice.length.should == 2
    dice.dice.each do |die|
      die.should be_an_instance_of(Rollables::Die)
      die.faces.length.should == 20
    end
  end

  it "should allow adding a single die" do
    Rollables::Dice.new.add_die(:d6).dice.length.should == 1
    Rollables::Dice.new(20).add_die(:d6).dice.length.should == 2
  end

  it "should allow adding multiple dice" do
    Rollables::Dice.new.add_dice([:d6, "2d8"]).dice.length.should == 3
    Rollables::Dice.new(20).add_dice([:d6, "2d8"]).dice.length.should == 4
  end

  it "should allow chaining the addition of dice" do
    Rollables::Dice.new.add_dice([6, 12]).add_die(:d8).add_dice("2d20").dice.length.should == 5
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
    Rollables::Dice.new(6, :d6, 12).to_s.should == "2d6,1d12"
    Rollables::Dice.new(1..6, "1d6").to_s.should == "2d6"
    Rollables::Dice.new("2d8", Rollables::Die.new(["a","b","c"]), Rollables::Die.new(["a","b","c"])).to_s.should == "2d8,2d(a,b,c)"
  end

  describe Rollables::DiceCollection do
    it "should allow adding a single die" do
      d1 = Rollables::Dice.new
      d1.dice.add_die(:d6)
      d1.dice.length.should == 1
      d2 = Rollables::Dice.new(20)
      d2.dice.add_die(:d6)
      d2.dice.length.should == 2
    end

    it "should allow adding multiple dice" do
      d1 = Rollables::Dice.new
      d1.dice.add_dice([:d6, "2d8"])
      d1.dice.length.should == 3
      d2 = Rollables::Dice.new(20)
      d2.dice.add_dice([:d6, "2d8"])
      d2.dice.length.should == 4
    end
    
    it "should allow chaining the addition of dice" do
      Rollables::Dice.new.dice.add_dice([6, 12]).add_die(:d8).add_dice("2d20").length.should == 5
    end
    
    it "should be numeric if all die have all numeric faces" do
      Rollables::Dice.new(:d6, 1..8, 20).dice.numeric?.should be_true
    end

    it "should not be numeric if any die have any non-numeric faces" do
      Rollables::Dice.new(:d6, Rollables::Die.new(["a","b","c"]), 20).dice.numeric?.should be_false
    end

    it "should be sequential if all die are all numeric and sequential" do
      Rollables::Dice.new(6, 12, Rollables::Die.new([2,5,3,4])).dice.sequential?.should be_true
    end

    it "should not be sequential if any die are non-numeric or non-sequential" do
      Rollables::Dice.new(6, Rollables::Die.new([1,2,3,4,"a"])).dice.sequential?.should be_false
      Rollables::Dice.new(6, :d20, Rollables::Die.new([2,5,4])).dice.sequential?.should be_false
    end

    it "should be simple if all die are all simple" do
      Rollables::Dice.new(6, 12, Rollables::Die.new([1,2,5,3,4])).dice.simple?.should be_true
    end

    it "should not be simple if any die are not simple" do
      Rollables::Dice.new(6, Rollables::Die.new([1,2,3,4,"a"])).dice.simple?.should be_false
      Rollables::Dice.new(6, :d20, Rollables::Die.new([2,3,4])).dice.simple?.should be_false
    end
    
    it "should return the correct value(s) for high" do
      Rollables::Dice.new(8, 20, 6).dice.high.should == 34
      Rollables::Dice.new(20, Rollables::Die.new([0,5,10])).dice.high.should == 30
      Rollables::Dice.new(6, 20, Rollables::Die.new(["a",2,3])).dice.high.should == [6,20,3]
    end
    
    it "should return the correct value(s) for low" do
      Rollables::Dice.new(8, 20, 6).dice.low.should == 3
      Rollables::Dice.new(20, Rollables::Die.new([0,5,10])).dice.low.should == 1
      Rollables::Dice.new(6, 20, Rollables::Die.new(["a",2,3])).dice.low.should == [1,1,"a"]
    end
  end

  describe Rollables::DiceRoll do
    it "should return a properly formatted string from to_s" do
      [Rollables::Dice.new(:d8, Rollables::Die.new([1,4,3,5,2])), Rollables::Dice.new(Rollables::Die.new(["a","b","c"]), 6), Rollables::Dice.new(1..12, Rollables::Die.new([2,5,1,9,8]))].each do |dice|
        roll = dice.roll
        if (dice.numeric?)
          roll.to_s.should == "#{roll.rolls.collect { |r| "#{r.die.to_s}=#{r.value.to_s}" }.join(" + ")} = #{roll.value.sum}"
        else
          roll.to_s.should == "#{roll.rolls.collect { |r| "#{r.die.to_s}=#{r.value.to_s}" }.join(" + ")} = (#{roll.value.join(",")})"
        end
      end
    end
    
    it "should return all the right face values for die rolls" do
      dice = Rollables::Dice.new("3d6")
      roll = dice.roll
      roll.value.should == roll.rolls.map(&:value)
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

end
