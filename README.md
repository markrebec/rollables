# Bones

Rollable dice for Ruby

## Installation

You can install the gem with:

    gem install bones

or by adding:

    gem 'bones'

in your Gemfile.

## Usage

### Single Die

    Bones::Die.new(6)                                               # => d6
    Bones::Die.new(20)                                              # => d20
    Bones::Die.new(:d8)                                             # => d8
    Bones::Die.new("1d12")                                          # => d12
    Bones::Die.new(1..6)                                            # => d6
    Bones::Die.new(5..10)                                           # => d(5,6,7,8,9,10)
    Bones::Die.new(["a","b","c"])                                   # => d(a,b,c)
    Bones::Die.new([0,5,10,20,40,80])                               # => d(0,5,10,20,40,80)

    die = Bones::Die.new(6)
    die.roll                                                        # => 3
    die.roll                                                        # => 1
    die.roll                                                        # => 5
    die.roll                                                        # => 1
    die.roll                                                        # => 6
    die.rolls                                                       # => [3, 1, 5, 1, 6]

### Collection of Dice

    Bones::Dice.new(6)                                              # => 1d6
    Bones::Dice.new("2d8")                                          # => 2d8
    Bones::Dice.new(:d6, "1d8", 12, 6)                              # => 2d6, 1d8, 1d12
    Bones::Dice.new([:d6, "2d8", 12])                               # => 1d6, 2d8, 1d12
    Bones::Dice.new(12, 6, Bones::Die.new([10,20,30]), "2d6")       # => 1d12, 3d6, 1d(10,20,30)
    Bones::Dice.new(1..12, "2d20", Bones::Die.new(["a","b","c"]))   # => 1d12, 2d20, 1d(a,b,c)

    dice = Bones::Dice.new(:d6, "1d8", 12, 6)
    dice.roll                                                       # => d6=1 + d8=1 + d12=12 + d6=6 = 20
    dice.roll                                                       # => d6=1 + d8=3 + d12=1 + d6=5 = 10
    dice.roll                                                       # => d6=5 + d8=6 + d12=1 + d6=4 = 16
    dice.roll                                                       # => d6=1 + d8=8 + d12=1 + d6=2 = 12
    dice.rolls                                                      # => [d6=1 + d8=1 + d12=12 + d6=6 = 20, d6=1 + d8=3 + d12=1 + d6=5 = 10, d6=5 + d8=6 + d12=1 + d6=4 = 16, d6=1 + d8=8 + d12=1 + d6=2 = 12]

    dice = Bones::Dice.new("2d6", Bones::Die(["x","y","z"]))
    dice.roll                                                       # => d6=3 + d6=1 + d(x,y,z)=y = (3,1,y)
    dice.roll                                                       # => d6=4 + d6=3 + d(x,y,z)=x = (4,3,x)
    dice.roll                                                       # => d6=1 + d6=2 + d(x,y,z)=x = (1,2,x)
    dice.rolls                                                      # => [d6=3 + d6=1 + d(x,y,z)=y = (3,1,y), d6=4 + d6=3 + d(x,y,z)=x = (4,3,x), d6=1 + d6=2 + d(x,y,z)=x = (1,2,x)]

## Testing

Bones uses `rspec` and has coverage for most functionalty provided in the `/spec` directory.  If you want to run specs against the codebase, execute `bundle exec rspec` from within the checked out repo.

## TODO

* Finish documentation
* Refactor some of the core objects to use modules and included behavior
* Support for more die faces besides strings and integers
