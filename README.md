# Rollables

Dice creator for Ruby with support for complex die notations, nested sets of dice, high/low drops, explode (#todo), roll modifiers and more.  

## Installation

### Requirements

Rollables only requires the enumerable features from the `activesupport` gem (which is registered as a dependency in the gemspec).

If you want to be able to print out the source code for your `proc` modifiers (to debug or explain what they're doing to the roll results), you should also install and require the [sourcify](https://github.com/ngty/sourcify) gem.  *The current version of `sourcify` (0.5.0) has a bug with double quotes. Until 0.6.0 is released, you might want to manually build and install from master (currently 0.6.0.rc2) instead. See [this thread](https://github.com/ngty/sourcify/issues/25) for details.*

### Install the Gem

**Note: I haven't submitted the gem to rubygems.org yet, so this won't work.  For now, clone the repo, build the gem and install it from there.**

You can install the gem with:

    gem install rollables

or by adding:

    gem 'rollables'

in your Gemfile.

You might also want to create base classes that inherit the `Rollables::Die` and `Rollables::Dice` functionality outside the `Rollables` namespace.  You can do that by creating a file with the following lines (for a rails app, `config/initializers/rollables.rb` is a good spot for this) and requiring it after `rollables` has been loaded:

    class Die < Rollables::Die; end
    class Dice < Rollables::Dice; end

That way you can just call `Die.new` or `Dice.new` to create new dice.

## Usage

### Single Die

Single die objects can be created with the `Die` class.  They can be rolled and can have modifiers applied to them, and can be converted to a Dice object (which can then be added to) with the `to_dice` instance method.

    # Creating Dice
    
    Rollables::Die.new(6)                           # => d6
    Rollables::Die.new("20")                        # => d20
    Rollables::Die.new(:d8)                         # => d8
    Rollables::Die.new("1d12")                      # => d12
    Rollables::Die.new("d12")                       # => d12
    Rollables::Die.new(1..6)                        # => d6
    Rollables::Die.new(5..10)                       # => d6(5,6,7,8,9,10)
    Rollables::Die.new(["a","b","c"])               # => d3(a,b,c)
    Rollables::Die.new([0,5,10,20,40,80])           # => d6(0,5,10,20,40,80)

    # Rolling
    
    die = Rollables::Die.new(6)
    die.roll                        # => 3
    die.roll                        # => 1
    die.roll                        # => 5
    die.roll                        # => 1
    die.roll                        # => 6
    die.rolls                       # => [3, 1, 5, 1, 6]

### Multiple Dice

Multiple dice can be created using the `Dice` class.  They can be rolled and can have modifiers or drops applied to them.

    # Creating Dice
    
    Rollables::Dice.new(6)                                                  # => 1d6
    Rollables::Dice.new("2d8")                                              # => 2d8
    Rollables::Dice.new(:d6, "1d8", 12, 6)                                  # => 2d6, 1d8, 1d12
    Rollables::Dice.new([:d6, "2d8", 12])                                   # => 1d6, 2d8, 1d12
    Rollables::Dice.new(12, 6, Rollables::Die.new([10,20,30]), "2d6")       # => 1d12, 3d6, 1d3(10,20,30)
    Rollables::Dice.new(1..12, "2d20", Rollables::Die.new(["a","b","c"]))   # => 1d12, 2d20, 1d3(a,b,c)
    
    # Rolling
    
    dice = Rollables::Dice.new(:d6, "1d8", 12, 6)
    dice.roll               # => 1 + 1 + 12 + 6 = 20
    dice.roll               # => 1 + 3 + 1 + 5 = 10
    dice.roll               # => 5 + 6 + 1 + 4 = 16
    dice.roll               # => 1 + 8 + 1 + 2 = 12
    dice.rolls              # => [1 + 1 + 12 + 6 = 20, 1 + 3 + 1 + 5 = 10, 5 + 6 + 1 + 4 = 16, 1 + 8 + 1 + 2 = 12]
    
    dice = Rollables::Dice.new("2d6", Rollables::Die(["x","y","z"]))
    dice.roll               # => 3 + 1 + y = 3,1,y
    dice.roll               # => 4 + 3 + x = 4,3,x
    dice.roll               # => 1 + 2 + x = 1,2,x
    dice.rolls              # => [3 + 1 + y = 3,1,y, 4 + 3 + x = 4,3,x, 1 + 2 + x = 1,2,x]

### Drops

Standard (and even some non-standard) drop notations are supported, allowing for neat things like multiple drops.  For example, `"5d6lh2"` would create 5 six-sided die, and when rolled would drop the single lowest and two highest values.

    # Apply to a Roll
    
    dice = Rollables::Dice.new("5d6")
    dice.roll                                 # => 2 + 5 + 1 + 5 + 3 = 16
    dice.roll(:drop => "l")                   # => 2 + 5 + (1) + 5 + 3 = 15 (the 1 is excluded from the total)
    
    # Apply to a Set of Dice
    
    dice = Rollables::Dice.new("5d6h2")       # drops the two highest die from each roll
    dice.roll                                 # => 2 + (5) + 1 + (5) + 3 = 6 (the two 5 are excluded from the total)
    dice.roll(:drop => "l")                   # => 2 + (5) + (1) + (5) + 3 = 5 (the 1 and two 5 are excluded from the total)
    

### Modifiers

Modifiers can be anything that can be eval'd or called against the result, such as a string like `"+5"` or a proc like `proc { |result| result + 5 }`.

    # Apply to a Roll
    
    die = Rollables::Die.new(:d6)
    die.roll                                                        # => 5
    die.roll(:modifier => "+5")                                     # => 5 +(5) = 10
    die.roll { |result| result + 10 }                               # => 5 +(10) = 15
    die.roll(:modifier => "+5") { |result| result + 10 }            # => 5 +(5) +(10) = 20
    
    dice = Rollables::Dice.new(:d6, "1d8", 12, 6)
    dice.roll                                                       # => 1 + 1 + 12 + 6 = 20
    dice.roll(:modifier => "+5")                                    # => 1 + 1 + 12 + 6 +(5) = 25
    dice.roll { |result| result + 10 }                              # => 1 + 1 + 12 + 6 +(10) = 30
    dice.roll(:modifier => "+5") { |result| result + 10 }           # => 1 + 1 + 12 + 6 +(5) +(10) = 35
    
    # Apply to a Die or Dice (for all rolls of those dice)
    
    die = Rollables::Die.new("1d6+5")
    die.roll                                                        # => 4 +(5) = 9
    die.roll(:modifier => "+5")                                     # => 4 +(5) +(5) = 14
    die.roll { |result| result + 10 }                               # => 4 +(5) +(10) = 19
    die.roll(:modifier => "+5") { |result| result + 10 }            # => 4 +(5) +(5) +(10) = 24
    
    dice = Rollables::Dice.new(:d6, "1d8+5", 12, 6)
    dice.roll                                                       # => 1 + (1 +(5)) + 12 + 6 = 25
    dice.roll(:modifier => "+5")                                    # => 1 + (1 +(5)) + 12 + 6 +(5) = 30
    dice.roll { |result| result + 10 }                              # => 1 + (1 +(5)) + 12 + 6 +(10) = 35
    dice.roll(:modifier => "+5") { |result| result + 10 }           # => 1 + (1 +(5)) + 12 + 6 +(5) +(10) = 40

### Custom Faces

Die have support for simple integer and string faces, but also allow you to supply custom faces (literally just about anything you want).  I've got plans to automate and build some of the basic stuff into `DieFace` (like automatically rolling the custom Die from the example below, rather than needing the custom block to do it).  Here is an example:

    # Six-sided die with a custom face in the #3 and #4 slots, which when hit roll another twelve-sided die, providing a
    # good chance to get up to a 2x bonus, or a slight chance to roll at or lower than the value of 3 or 4 that would
    # normally have been there.
    d8proc = proc { Die.new(12).roll }
    d6custom = Die.new([1, 2, d12proc, d12proc, 5, 6])
    20.times { d6custom.roll { |result| result.respond_to?(:call) ? result.call : result } }
    d6custom.rolls          # => [6, 8, 2, 9, 10, 6, 8, 9, 5, 1, 2, 2, 2, 2, 1, 1, 6, 3, 6, 2]

## Tests

Rollables uses `rspec` and has coverage for most functionalty provided in the `/spec` directory.  If you want to run specs against the codebase, execute `bundle exec rspec` from within the checked out repo.

## TODO

* Finish documentation
* Refactor some of the core objects to use modules and included behavior
* Add support for rolling the dice `x` times
* Add support for applying math to dice roll results. Example: `(1d6 * 1d3) + 1d8` instead of `1d6 + 1d3 + 1d8`
* Implement 'explode'
