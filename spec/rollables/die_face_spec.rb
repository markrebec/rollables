require 'rollables'

describe Rollables::DieFace do
  it "should return the correct modified instance" do
    die = Rollables::Die.new([1,"2","z"])
    die[0].should be_a(Integer)
    die[1].should be_a(Integer)
    die[2].should be_a(String)
  end

  it "should not allow unsupported formats" do
    expect { Rollables::Die.new([1,2,:d]) }.to raise_exception
    expect { Rollables::Die.new([1,2,[]]) }.to raise_exception
    expect { Rollables::Die.new([1,2,{}]) }.to raise_exception
    expect { Rollables::Die.new([1,2,Object.new]) }.to raise_exception
  end
end
