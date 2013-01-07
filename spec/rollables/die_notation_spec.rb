require 'rollables'

describe Rollables::DieNotation do

  it "should be able to be instantiated" do
    Rollables::DieNotation.new(6).should be_an_instance_of(Rollables::DieNotation)
  end

  it "should not allow an empty notation" do
    expect { Rollables::DieNotation.new() }.to raise_exception
  end

  it "should require 2 or more faces" do
    expect { Rollables::DieNotation.new(1) }.to raise_exception
    expect { Rollables::DieNotation.new(["a"]) }.to raise_exception
  end

  it "should default to a single die" do
    Rollables::DieNotation.new(8).dice.should == 1
    Rollables::DieNotation.new("6").dice.should == 1
    Rollables::DieNotation.new("d8").dice.should == 1
    Rollables::DieNotation.new("d8+10").dice.should == 1
    Rollables::DieNotation.new("d12+(10*10)").dice.should == 1
  end

  it "should accept an integer" do
    n = Rollables::DieNotation.new(6)
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 6
    n.drop.should be_nil
    n.modifier.should be_nil
  end
  
  it "should accept a range" do
    n = Rollables::DieNotation.new(1..8)
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should be_nil
    n.modifier.should be_nil
  end
  
  it "should accept an array" do
    n = Rollables::DieNotation.new(["a","b","c","d","e","f"])
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 6
    n.drop.should be_nil
    n.modifier.should be_nil
  end
  
  it "should accept a symbol" do
    n = Rollables::DieNotation.new(:d12)
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 12
    n.drop.should be_nil
    n.modifier.should be_nil
  end

  it "should accept a string formatted with 'Y'" do
    n = Rollables::DieNotation.new("6")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 6
    n.drop.should be_nil
    n.modifier.should be_nil
  end

  it "should accept a string formatted with 'dY'" do
    n = Rollables::DieNotation.new("d6")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 6
    n.drop.should be_nil
    n.modifier.should be_nil
  end

  it "should accept a string formatted with 'XdY'" do
    n = Rollables::DieNotation.new("2d6")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 2
    n.faces.length.should == 6
    n.drop.should be_nil
    n.modifier.should be_nil
  end

  it "should accept a string formatted with 'XdYS'" do
    n = Rollables::DieNotation.new("5d6l")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 5
    n.faces.length.should == 6
    n.drop.type.should == 'l'
    n.drop.count.should == 1
    n.modifier.should be_nil
    
    n = Rollables::DieNotation.new("5d6h2")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 5
    n.faces.length.should == 6
    n.drop.type.should == 'h'
    n.drop.count.should == 2
    n.modifier.should be_nil
  end

  it "should accept a string formatted with 'XdYSM'" do
    n = Rollables::DieNotation.new("4d8l1+(2*10)")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 4
    n.faces.length.should == 8
    n.drop.type.should == 'l'
    n.drop.count.should == 1
    n.modifier.raw.should == '+(2*10)'
    
    n = Rollables::DieNotation.new("3d8h+(2*10)")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 3
    n.faces.length.should == 8
    n.drop.type.should == 'h'
    n.drop.count.should == 1
    n.modifier.raw.should == '+(2*10)'
  end

  it "should accept a string formatted with 'XdYM'" do
    n = Rollables::DieNotation.new("4d12+10")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 4
    n.faces.length.should == 12
    n.drop.should be_nil
    n.modifier.raw.should == '+10'
  end

  it "should not accept a string formatted with 'dYSM'" do
    expect { Rollables::DieNotation.new("d8h+(2*10)") }.to raise_exception
  end

  it "should accept a string formatted with 'dYS'" do
    expect { Rollables::DieNotation.new("d8h") }.to raise_exception
  end

  it "should accept a string formatted with 'dYM'" do
    n = Rollables::DieNotation.new("d8+(2*10)")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should be_nil
    n.modifier.raw.should == '+(2*10)'
  end

  it "should not accept a string formatted with 'YSM'" do
    expect { Rollables::DieNotation.new("8h+(2*10)") }.to raise_exception
  end

  it "should not accept a string formatted with 'YS'" do
    expect { Rollables::DieNotation.new("8l") }.to raise_exception
  end

  it "should not accept invalid notation strings" do
    expect { Rollables::DieNotation.new("2d") }.to raise_exception
    expect { Rollables::DieNotation.new("2d8b") }.to raise_exception
    expect { Rollables::DieNotation.new("abc") }.to raise_exception
    expect { Rollables::DieNotation.new("d") }.to raise_exception
    expect { Rollables::DieNotation.new("h") }.to raise_exception
    expect { Rollables::DieNotation.new("2dl") }.to raise_exception
    expect { Rollables::DieNotation.new("1d+20") }.to raise_exception
  end

  it "should not allow more than (num_dice-1) to be dropped" do
    expect { Rollables::DieNotation.new("2d6l2") }.to raise_exception
    expect { Rollables::DieNotation.new("4d8l5+10") }.to raise_exception
  end

  it "should return a new dice object from #create" do
    Rollables::DieNotation.create(6).should be_an_instance_of(Rollables::Die)
    Rollables::DieNotation.create("1d6").should be_an_instance_of(Rollables::Die)
    Rollables::DieNotation.create("1d6 6").should be_an_instance_of(Rollables::Dice)
    Rollables::DieNotation.create("2d6 12").should be_an_instance_of(Rollables::Dice)
  end

  it "should be considered common if it is a common six-sided die" do
    Rollables::DieNotation.new(6).common?.should be_true
    Rollables::DieNotation.new(1..6).common?.should be_true
    Rollables::DieNotation.new(["3",4,2,6,"1","5"]).common?.should be_true
    Rollables::DieNotation.new(:d12).common?.should be_false
    Rollables::DieNotation.new(1..8).common?.should be_false
  end

  it "should return the correct value from drop?" do
    Rollables::DieNotation.new("3d6l").drop?.should be_true
    Rollables::DieNotation.new("4d8h2").drop?.should be_true
    Rollables::DieNotation.new("6d12l3+(10*10)").drop?.should be_true
    Rollables::DieNotation.new(8).drop?.should be_false
    Rollables::DieNotation.new(:d12).drop?.should be_false
    Rollables::DieNotation.new("2d6+10").drop?.should be_false
  end
  
  it "should be considered numeric if all face values are integers" do
    Rollables::DieNotation.new(6).numeric?.should be_true
    Rollables::DieNotation.new("2d8+5").numeric?.should be_true
    Rollables::DieNotation.new("d12").numeric?.should be_true
    Rollables::DieNotation.new(3..10).numeric?.should be_true
    Rollables::DieNotation.new(["1","3","5","7","9"]).numeric?.should be_true
    Rollables::DieNotation.new([1,2,3,"a","b","c"]).numeric?.should be_false
  end

  it "should be considered sequential if all face values are numeric and sequential" do
    Rollables::DieNotation.new(6).sequential?.should be_true
    Rollables::DieNotation.new("2d8+5").sequential?.should be_true
    Rollables::DieNotation.new("d12").sequential?.should be_true
    Rollables::DieNotation.new(3..10).sequential?.should be_true
    Rollables::DieNotation.new([5,2,3,6,1,4]).sequential?.should be_true
    Rollables::DieNotation.new(["1","3","5","7","9"]).sequential?.should be_false
    Rollables::DieNotation.new([1,2,3,"a","b","c"]).sequential?.should be_false
  end

  it "should be considered simple if all face values are numeric and sequential and the low value is 1" do
    Rollables::DieNotation.new(6).simple?.should be_true
    Rollables::DieNotation.new("2d8+5").simple?.should be_true
    Rollables::DieNotation.new("d12").simple?.should be_true
    Rollables::DieNotation.new([5,2,3,6,1,4]).simple?.should be_true
    Rollables::DieNotation.new(3..10).simple?.should be_false
    Rollables::DieNotation.new([5,2,3,6,4,7]).simple?.should be_false
    Rollables::DieNotation.new(["1","3","5","7","9"]).simple?.should be_false
    Rollables::DieNotation.new([1,2,3,"a","b","c"]).simple?.should be_false
  end

  it "should return the correct high face value" do
    Rollables::DieNotation.new(12).high.should == 12
    Rollables::DieNotation.new("3d6").high.should == 6
    Rollables::DieNotation.new([3,5,8,6,4,7]).high.should == 8
    Rollables::DieNotation.new(["x","b","a","z","y","c"]).high.should == "c"
  end

  it "should return the correct low face value" do
    Rollables::DieNotation.new(12).low.should == 1
    Rollables::DieNotation.new("3d6").low.should == 1
    Rollables::DieNotation.new([3,5,8,6,4,7]).low.should == 3
    Rollables::DieNotation.new(["x","b","a","z","y","c"]).low.should == "x"
  end

  it "should be able to reset itself" do
    n = Rollables::DieNotation.new("2d8l+10")
    n.reset
    n.dice.should == 1
    n.faces.length.should == 0
    n.drop.should be_nil
    n.modifier.should be_nil
  end

  it "should return a notation describing a single die from singular" do
    n = Rollables::DieNotation.new("3d8l+10").singular
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should be_nil
    n.modifier.should be_nil
  end

  it "should be considered singular if it describes only one die" do
    Rollables::DieNotation.new("3d8l+10").singular?.should be_false
    Rollables::DieNotation.new("2d6").singular?.should be_false
    Rollables::DieNotation.new(12).singular?.should be_true
    Rollables::DieNotation.new("1d12").singular?.should be_true
  end

  it "should return a new dice object from to_d" do
    Rollables::DieNotation.new("3d8").to_d.should be_an_instance_of(Rollables::Dice)
    Rollables::DieNotation.new(8).to_d.should be_an_instance_of(Rollables::Die)
  end

  it "should return a properly formatted string from to_s" do
    Rollables::DieNotation.new(6).to_s.should == "1d6"
    Rollables::DieNotation.new("3d8+10").to_s.should == "3d8+10"
    Rollables::DieNotation.new("2d8h+10").to_s.should == "2d8h+10"
    Rollables::DieNotation.new("5d12l2+5").to_s.should == "5d12l2+5"
    Rollables::DieNotation.new("d6").to_s.should == "1d6"
    Rollables::DieNotation.new(8..10).to_s.should == "1d3(8,9,10)"
    Rollables::DieNotation.new(["a","b","c"]).to_s.should == "1d3(a,b,c)"
  end

  it "should accept a string formatted with 'YM'" do
    n = Rollables::DieNotation.new("8+10")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should be_nil
    n.modifier.raw.should == '+10'
  end

  it "should convert a single notation string to a new object with #parse" do
    Rollables::DieNotation.parse(6).should be_an_instance_of(Rollables::DieNotation)
    Rollables::DieNotation.parse("1d6+5").should be_an_instance_of(Rollables::DieNotation)
  end

  it "should convert multiple notation strings to an array of new objects with #parse" do
    Rollables::DieNotation.parse("6+10 2d8").should be_a(Rollables::DieNotationArray)
    Rollables::DieNotation.parse("1d8 1d12 1d6").should be_a(Rollables::DieNotationArray)
  end
end
