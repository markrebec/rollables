require 'rollables'

describe Rollables::Die do
  
  it "should be a valid instance of itself" do
    Rollables::Die.new(6).should be_an_instance_of(Rollables::Die)
  end

  it "should allow instantiation with a range" do
    Rollables::Die.new(1..6).should be_an_instance_of(Rollables::Die)
  end

  it "should allow instantiation with an array" do
    Rollables::Die.new([1,2,3,4,5,6]).should be_an_instance_of(Rollables::Die)
  end

  it "should allow instantiation with an integer" do
    die = Rollables::Die.new(6)
    die.should be_an_instance_of(Rollables::Die)
    die.faces.length.should == 6
  end

  it "should allow instantiation with a string" do
    die = Rollables::Die.new("6")
    die.should be_an_instance_of(Rollables::Die)
    die.faces.length.should == 6
  end

  it "should allow instantiation with a :d20 formatted symbol" do
    die = Rollables::Die.new(:d20)
    die.should be_an_instance_of(Rollables::Die)
    die.faces.length.should == 20
  end

  it "should allow instantiation with a 'd20' formatted string" do
    die = Rollables::Die.new("d20")
    die.should be_an_instance_of(Rollables::Die)
    die.faces.length.should == 20
  end

  it "should allow instantiation with a '1d20' formatted string" do
    die = Rollables::Die.new("1d20")
    die.should be_an_instance_of(Rollables::Die)
    die.faces.length.should == 20
  end
  
  it "should not allow instantiation with greater than 1 die" do
    expect { die = Rollables::Die.new("2d20") }.to raise_exception
  end

  it "should not allow instantiation with an invalid string" do
    expect { die = Rollables::Die.new("abc") }.to raise_exception
  end

  it "should require 2 or more faces" do
    expect { Rollables::Die.new(1) }.to raise_exception
    expect { Rollables::Die.new(0) }.to raise_exception
    expect { Rollables::Die.new(-2) }.to raise_exception
  end

  it "should have the correct assigned number of faces" do
    Rollables::Die.new(6).faces.length.should == 6
  end

  it "should have the correct assigned values for all faces" do
    die = Rollables::Die.new(["one", "two", "three", "four", "five", "six"])
    die.faces[0].should == "one"
    die.faces[1].should == "two"
    die.faces[2].should == "three"
    die.faces[3].should == "four"
    die.faces[4].should == "five"
    die.faces[5].should == "six"
  end

  it "should be numeric if all faces have numeric values" do
    Rollables::Die.new(6).numeric?.should be_true
    Rollables::Die.new([2,88,54,12,6]).numeric?.should be_true
    Rollables::Die.new(["6","2","487"]).numeric?.should be_true
  end

  it "should not be numeric if any faces have non-numeric values" do
    Rollables::Die.new([1,2,"c"]).numeric?.should be_false
  end

  it "should be sequential if all faces are numeric and sequential" do
    Rollables::Die.new(6).sequential?.should be_true
    Rollables::Die.new(:d6).sequential?.should be_true
    Rollables::Die.new([1,2,3]).sequential?.should be_true
    Rollables::Die.new(["7","8","9"]).sequential?.should be_true
  end

  it "should not be sequential if any faces are non-numeric" do
    Rollables::Die.new(["a","b","c"]).sequential?.should be_false
    Rollables::Die.new([1,2,3,"a"]).sequential?.should be_false
  end
  
  it "should not be sequential if any faces are non-sequential" do
    Rollables::Die.new([1,3,5,7,9]).sequential?.should be_false
  end

  it "should be simple if all faces are numeric and sequential and the low value is 1" do
    Rollables::Die.new(:d6).simple?.should be_true
    Rollables::Die.new(1..3).simple?.should be_true
  end

  it "should not be simple if any faces are non-numeric" do
    Rollables::Die.new(["a","b","c"]).simple?.should be_false
    Rollables::Die.new([1,2,3,"a"]).simple?.should be_false
  end

  it "should not be simple if any faces are non-sequential" do
    Rollables::Die.new([2,5,9]).simple?.should be_false
  end

  it "should not be simple if the low value is not 1" do
    Rollables::Die.new(2..7).simple?.should be_false
  end

  it "should be common if it is a sequential 6-sided die with face values of 1-6" do
    Rollables::Die.new("1d6").common?.should be_true
    Rollables::Die.new(1..6).common?.should be_true
  end

  it "should only be common if it is a sequential 6-sided die with face values of 1-6" do
    Rollables::Die.new(5).common?.should be_false
    Rollables::Die.new([1,3,4,5,6,7]).common?.should be_false
    Rollables::Die.new([2,3,4,5,6,7]).common?.should be_false
  end

  it "should return the correct face value for high" do
    Rollables::Die.new(20).high.should == 20
    Rollables::Die.new([7,2,9,5,4]).high.should == 9
    Rollables::Die.new(["a","b","c"]).high.should == "c"
    Rollables::Die.new(["c","b","a"]).high.should == "a"
  end

  it "should return the correct face value for low" do
    Rollables::Die.new(20).low.should == 1
    Rollables::Die.new([7,2,9,5,4]).low.should == 2
    Rollables::Die.new(["a","b","c"]).low.should == "a"
    Rollables::Die.new(["b","c","a"]).low.should == "b"
  end

  it "should sort numeric faces when comparing high/low" do
    Rollables::Die.new([7,2,9,5,4]).high.should == 9
    Rollables::Die.new([7,2,9,5,4]).low.should == 2
  end

  it "should leave order intact for non-numeric faces when comparing high/low" do
    Rollables::Die.new(["a","b","c"]).high.should == "c"
    Rollables::Die.new(["a","b","c"]).low.should == "a"
    Rollables::Die.new(["b","c","a"]).high.should == "a"
    Rollables::Die.new(["b","c","a"]).low.should == "b"
  end

  it "should be able to be rolled" do
    Rollables::Die.new(6).roll.should be_an_instance_of(Rollables::Die::DieRoll)
  end

  it "should always return a face value within it's parameters when rolled" do
    [Rollables::Die.new(6), Rollables::Die.new(:d12), Rollables::Die.new(["a","b","c"])].each do |die|
      20.times { die.faces.include?(die.roll.value).should be_true }
    end
  end

  it "should return a properly formatted string from to_s" do
    Rollables::Die.new(20).to_s.should == "d20"
    Rollables::Die.new(:d6).to_s.should == "d6"
    Rollables::Die.new(["1","2","3"]).to_s.should == "d3"
    Rollables::Die.new(2..4).to_s.should == "d(2,3,4)"
    Rollables::Die.new(["x","y","z"]).to_s.should == "d(x,y,z)"
  end

  describe Rollables::Die::DieRoll do
    it "should roll on init" do
      die = Rollables::Die.new(:d6)
      roll = die.roll
      roll.value.should_not be_nil
      roll.timestamp.should_not be_nil
    end

    it "should return a properly formatted string from to_s" do
      [Rollables::Die.new(6), Rollables::Die.new(["a","b","c","hello"])].each do |die|
        20.times do
          roll = die.roll
          roll.to_s.should == roll.value.to_s
        end
      end
    end
  end

  describe Rollables::Die::DieRolls do
    it "should return a properly formatted string from to_s" do
      [Rollables::Die.new(6), Rollables::Die.new(["z","y","x"])].each do |die|
        5.times { die.roll }
        die.rolls.to_s.should == die.rolls.collect { |roll| roll.value }.join(",")
      end
    end
  end
  
  describe Rollables::Die::DieFace do
    it "should return the correct modified instance" do
      die = Rollables::Die.new([1,"2","z"])
      die.faces[0].should be_a(Integer)
      die.faces[1].should be_a(Integer)
      die.faces[2].should be_a(String)
    end

    it "should not allow unsupported formats" do
      expect { Rollables::Die.new([1,2,:d]) }.to raise_exception
      expect { Rollables::Die.new([1,2,[]]) }.to raise_exception
      expect { Rollables::Die.new([1,2,{}]) }.to raise_exception
      expect { Rollables::Die.new([1,2,Object.new]) }.to raise_exception
    end
  end

  describe Rollables::Die::DieFaces do
    it "should allow valid DieFace formats" do
      Rollables::Die.new([1,"b2"]).faces.should be_an_instance_of(Rollables::Die::DieFaces)
    end
    
    it "should not allow invalid DieFace formats" do
      expect { Rollables::Die.new([1,2,:d]) }.to raise_exception
      expect { Rollables::Die.new([1,2,[]]) }.to raise_exception
      expect { Rollables::Die.new([1,2,{}]) }.to raise_exception
      expect { Rollables::Die.new([1,2,Object.new]) }.to raise_exception
    end
    
    it "should return a properly formatted string from to_s" do
      [Rollables::Die.new(1..6), Rollables::Die.new(:d8), Rollables::Die.new([2,3,4,5]), Rollables::Die.new([1,"3","a","hi"])].each do |die|
        die.faces.to_s.should == die.faces.join(",")
      end
    end

    it "should be numeric if all faces have numeric values" do
      Rollables::Die.new(6).faces.numeric?.should be_true
      Rollables::Die.new([2,88,54,12,6]).faces.numeric?.should be_true
      Rollables::Die.new(["6","2","487"]).faces.numeric?.should be_true
    end

    it "should not be numeric if any faces have non-numeric values" do
      Rollables::Die.new(["a","b","c"]).faces.numeric?.should be_false
    end

    it "should be sequential if all faces are numeric and sequential" do
      Rollables::Die.new(6).faces.sequential?.should be_true
      Rollables::Die.new(:d6).faces.sequential?.should be_true
      Rollables::Die.new([1,2,3]).faces.sequential?.should be_true
      Rollables::Die.new(["7","8","9"]).faces.sequential?.should be_true
    end

    it "should not be sequential if any faces are non-numeric" do
      Rollables::Die.new(["a","b","c"]).faces.sequential?.should be_false
      Rollables::Die.new([1,2,3,"a"]).faces.sequential?.should be_false
    end
    
    it "should not be sequential if any faces are non-sequential" do
      Rollables::Die.new([1,3,5,7,9]).faces.sequential?.should be_false
    end

    it "should be simple if all faces are numeric and sequential and the low value is 1" do
      Rollables::Die.new(:d6).faces.simple?.should be_true
      Rollables::Die.new(1..3).faces.simple?.should be_true
    end

    it "should not be simple if any faces are non-numeric" do
      Rollables::Die.new(["a","b","c"]).faces.simple?.should be_false
      Rollables::Die.new([1,2,3,"a"]).faces.simple?.should be_false
    end

    it "should not be simple if any faces are non-sequential" do
      Rollables::Die.new([2,5,9]).faces.simple?.should be_false
    end

    it "should not be simple if the low value is not 1" do
      Rollables::Die.new(2..7).faces.simple?.should be_false
    end

    it "should be common if it is a a sequential 6-sided die with face values of 1-6" do
      Rollables::Die.new("1d6").faces.common?.should be_true
      Rollables::Die.new(1..6).faces.common?.should be_true
    end

    it "should only be common if it is a sequential 6-sided die with face values of 1-6" do
      Rollables::Die.new(5).faces.common?.should be_false
      Rollables::Die.new([1,3,4,5,6,7]).faces.common?.should be_false
      Rollables::Die.new([2,3,4,5,6,7]).faces.common?.should be_false
    end

    it "should return the correct face value for high" do
      Rollables::Die.new(20).faces.high.should == 20
      Rollables::Die.new([7,2,9,5,4]).faces.high.should == 9
      Rollables::Die.new(["a","b","c"]).faces.high.should == "c"
      Rollables::Die.new(["c","b","a"]).faces.high.should == "a"
    end

    it "should return the correct face value for low" do
      Rollables::Die.new(20).faces.low.should == 1
      Rollables::Die.new([7,2,9,5,4]).faces.low.should == 2
      Rollables::Die.new(["a","b","c"]).faces.low.should == "a"
      Rollables::Die.new(["b","c","a"]).faces.low.should == "b"
    end

    it "should sort numeric faces when comparing high/low" do
      Rollables::Die.new([7,2,9,5,4]).faces.high.should == 9
      Rollables::Die.new([7,2,9,5,4]).faces.low.should == 2
    end

    it "should leave order intact for non-numeric faces when comparing high/low" do
      Rollables::Die.new(["a","b","c"]).faces.high.should == "c"
      Rollables::Die.new(["a","b","c"]).faces.low.should == "a"
      Rollables::Die.new(["b","c","a"]).faces.high.should == "a"
      Rollables::Die.new(["b","c","a"]).faces.low.should == "b"
    end
  end
  
end
