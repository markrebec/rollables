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
    Rollables::DieNotation.new("8").dice.should == 1
    Rollables::DieNotation.new("d8").dice.should == 1
    Rollables::DieNotation.new("8L").dice.should == 1
    Rollables::DieNotation.new("d8+10").dice.should == 1
    Rollables::DieNotation.new("8H+10").dice.should == 1
    Rollables::DieNotation.new("d8L+(10*10)").dice.should == 1
  end

  it "should accept an integer" do
    n = Rollables::DieNotation.new(6)
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 6
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
    n.drop.should == 'L'
    n.modifier.should be_nil
  end

  it "should accept a string formatted with 'XdYSM'" do
    n = Rollables::DieNotation.new("3d8h+(2*10)")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 3
    n.faces.length.should == 8
    n.drop.should == 'H'
    n.modifier.should == '+(2*10)'
  end

  it "should accept a string formatted with 'XdYM'" do
    n = Rollables::DieNotation.new("4d12+10")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 4
    n.faces.length.should == 12
    n.drop.should be_nil
    n.modifier.should == '+10'
  end

  it "should accept a string formatted with 'dYSM'" do
    n = Rollables::DieNotation.new("d8h+(2*10)")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should == 'H'
    n.modifier.should == '+(2*10)'
  end

  it "should accept a string formatted with 'dYS'" do
    n = Rollables::DieNotation.new("d8h")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should == 'H'
    n.modifier.should be_nil
  end

  it "should accept a string formatted with 'dYM'" do
    n = Rollables::DieNotation.new("d8+(2*10)")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should be_nil
    n.modifier.should == '+(2*10)'
  end

  it "should accept a string formatted with 'YSM'" do
    n = Rollables::DieNotation.new("8h+(2*10)")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should == 'H'
    n.modifier.should == '+(2*10)'
  end

  it "should accept a string formatted with 'YS'" do
    n = Rollables::DieNotation.new("8l")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should == 'L'
    n.modifier.should be_nil
  end

  pending "should not accept invalid notation strings"
  pending "should return new dice objects from #create"
  pending "common?"
  pending "numeric?"
  pending "sequential?"
  pending "simple?"
  pending "high"
  pending "low"
  pending "reset"
  pending "singular"
  pending "to_d"
  pending "to_s"

  it "should accept a string formatted with 'YM'" do
    n = Rollables::DieNotation.new("8+10")
    n.should be_an_instance_of(Rollables::DieNotation)
    n.dice.should == 1
    n.faces.length.should == 8
    n.drop.should be_nil
    n.modifier.should == '+10'
  end

  it "should instantiate a new object from #parse" do
    Rollables::DieNotation.parse(6).should be_an_instance_of(Rollables::DieNotation)
  end
end
