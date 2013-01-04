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

    Rollables::Die.new(6)                                               # => d6
    Rollables::Die.new(20)                                              # => d20
    Rollables::Die.new(:d8)                                             # => d8
    Rollables::Die.new("1d12")                                          # => d12
    Rollables::Die.new(1..6)                                            # => d6
    Rollables::Die.new(5..10)                                           # => d(5,6,7,8,9,10)
    Rollables::Die.new(["a","b","c"])                                   # => d(a,b,c)
    Rollables::Die.new([0,5,10,20,40,80])                               # => d(0,5,10,20,40,80)

    die = Rollables::Die.new(6)
    die.roll                                                        # => 3
    die.roll                                                        # => 1
    die.roll                                                        # => 5
    die.roll                                                        # => 1
    die.roll                                                        # => 6
    die.rolls                                                       # => [3, 1, 5, 1, 6]

### Collection of Dice

    Rollables::Dice.new(6)                                              # => 1d6
    Rollables::Dice.new("2d8")                                          # => 2d8
    Rollables::Dice.new(:d6, "1d8", 12, 6)                              # => 2d6, 1d8, 1d12
    Rollables::Dice.new([:d6, "2d8", 12])                               # => 1d6, 2d8, 1d12
    Rollables::Dice.new(12, 6, Rollables::Die.new([10,20,30]), "2d6")       # => 1d12, 3d6, 1d(10,20,30)
    Rollables::Dice.new(1..12, "2d20", Rollables::Die.new(["a","b","c"]))   # => 1d12, 2d20, 1d(a,b,c)

    dice = Rollables::Dice.new(:d6, "1d8", 12, 6)
    dice.roll                                                       # => d6=1 + d8=1 + d12=12 + d6=6 = 20
    dice.roll                                                       # => d6=1 + d8=3 + d12=1 + d6=5 = 10
    dice.roll                                                       # => d6=5 + d8=6 + d12=1 + d6=4 = 16
    dice.roll                                                       # => d6=1 + d8=8 + d12=1 + d6=2 = 12
    dice.rolls                                                      # => [d6=1 + d8=1 + d12=12 + d6=6 = 20, d6=1 + d8=3 + d12=1 + d6=5 = 10, d6=5 + d8=6 + d12=1 + d6=4 = 16, d6=1 + d8=8 + d12=1 + d6=2 = 12]

    dice = Rollables::Dice.new("2d6", Rollables::Die(["x","y","z"]))
    dice.roll                                                       # => d6=3 + d6=1 + d(x,y,z)=y = (3,1,y)
    dice.roll                                                       # => d6=4 + d6=3 + d(x,y,z)=x = (4,3,x)
    dice.roll                                                       # => d6=1 + d6=2 + d(x,y,z)=x = (1,2,x)
    dice.rolls                                                      # => [d6=3 + d6=1 + d(x,y,z)=y = (3,1,y), d6=4 + d6=3 + d(x,y,z)=x = (4,3,x), d6=1 + d6=2 + d(x,y,z)=x = (1,2,x)]

## Tests

Rollables uses `rspec` and has coverage for most functionalty provided in the `/spec` directory.  If you want to run specs against the codebase, execute `bundle exec rspec` from within the checked out repo.

## TODO

* Finish documentation
* Refactor some of the core objects to use modules and included behavior
* Support for more die faces besides strings and integers
* Require ActiveSupport for arrays? Or port over the `Array.sum` to replace the temp one in place right now (and add specs)?
* Add support for rolling the dice `x` times
* Add support for RPG features like `XdY + Z` modifiers and such
* Add flag to control whether numeric values are added together even when all faces are not numeric
* Add support for applying math to dice. Example: `(1d6 * 1d3) + 1d8` instead of `1d6 + 1d3 + 1d8`
* Implement 'drop low,' 'drop high,' and 'explode' + their notations

