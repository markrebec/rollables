# Rollables

Rollable dice for Ruby

## Installation

You can install the gem with:

    gem install rollables

or by adding:

    gem 'rollables'

in your Gemfile.

## Usage

### Single Die

    # Creating Dice
    
    Rollables::Die.new(6)                                               # => d6
    Rollables::Die.new("20")                                            # => d20
    Rollables::Die.new(:d8)                                             # => d8
    Rollables::Die.new("1d12")                                          # => d12
    Rollables::Die.new("d12")                                           # => d12
    Rollables::Die.new(1..6)                                            # => d6
    Rollables::Die.new(5..10)                                           # => d6(5,6,7,8,9,10)
    Rollables::Die.new(["a","b","c"])                                   # => d3(a,b,c)
    Rollables::Die.new([0,5,10,20,40,80])                               # => d6(0,5,10,20,40,80)

    # Rolling
    
    die = Rollables::Die.new(6)
    die.roll                                                            # => 3
    die.roll                                                            # => 1
    die.roll                                                            # => 5
    die.roll                                                            # => 1
    die.roll                                                            # => 6
    die.rolls                                                           # => [3, 1, 5, 1, 6]

### Multiple Dice

    # Creating Dice

    Rollables::Dice.new(6)                                                  # => 1d6
    Rollables::Dice.new("2d8")                                              # => 2d8
    Rollables::Dice.new(:d6, "1d8", 12, 6)                                  # => 2d6, 1d8, 1d12
    Rollables::Dice.new([:d6, "2d8", 12])                                   # => 1d6, 2d8, 1d12
    Rollables::Dice.new(12, 6, Rollables::Die.new([10,20,30]), "2d6")       # => 1d12, 3d6, 1d3(10,20,30)
    Rollables::Dice.new(1..12, "2d20", Rollables::Die.new(["a","b","c"]))   # => 1d12, 2d20, 1d3(a,b,c)

    # Rolling

    dice = Rollables::Dice.new(:d6, "1d8", 12, 6)
    dice.roll                                                           # => 1 + 1 + 12 + 6 = 20
    dice.roll                                                           # => 1 + 3 + 1 + 5 = 10
    dice.roll                                                           # => 5 + 6 + 1 + 4 = 16
    dice.roll                                                           # => 1 + 8 + 1 + 2 = 12
    dice.rolls                                                          # => [1 + 1 + 12 + 6 = 20, 1 + 3 + 1 + 5 = 10, 5 + 6 + 1 + 4 = 16, 1 + 8 + 1 + 2 = 12]

    dice = Rollables::Dice.new("2d6", Rollables::Die(["x","y","z"]))
    dice.roll                                                           # => 3 + 1 + y = 3,1,y
    dice.roll                                                           # => 4 + 3 + x = 4,3,x
    dice.roll                                                           # => 1 + 2 + x = 1,2,x
    dice.rolls                                                          # => [3 + 1 + y = 3,1,y, 4 + 3 + x = 4,3,x, 1 + 2 + x = 1,2,x]

### Drops

### Modifiers

    # Apply to a Single Roll
    dice = Rollables::Dice.new(:d6, "1d8", 12, 6)
    dice.roll { |result| result + 10 }                              # => 1 + 1 + 12 + 6 = 30   (adds an extra value of +10 to the result set)
    dice.roll                                                       # => 5 + 6 + 1 + 4 = 16

## Tests

Rollables uses `rspec` and has coverage for most functionalty provided in the `/spec` directory.  If you want to run specs against the codebase, execute `bundle exec rspec` from within the checked out repo.

## TODO

* Finish documentation
* Refactor some of the core objects to use modules and included behavior
* Support for more die faces besides strings and integers
* Support for die faces with behaviors. Example: d(1,2,X,5,6) - "X" would roll a 1d6 3 times and pick the lowest result
* Add support for rolling the dice `x` times
* Add support for applying math to dice. Example: `(1d6 * 1d3) + 1d8` instead of `1d6 + 1d3 + 1d8`
* Implement 'drop low,' 'drop high,' and 'explode' + their notations

