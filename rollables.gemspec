$:.push File.expand_path("../lib", __FILE__)
require "rollables/version"

Gem::Specification.new do |s|
  s.name        = "rollables"
  s.version     = Rollables::VERSION
  s.date        = "2012-01-04"
  s.summary     = "Dice creator for Ruby."
  s.description = "Dice creator for Ruby with support for complex die notations, sets of dice, drops, explode, roll modifiers and more."
  s.authors     = ["Mark Rebec"]
  s.email       = ["mark@markrebec.com"]
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["spec/**/*"]
  s.homepage    = "http://github.com/markrebec/rollables"

  s.add_development_dependency "rspec"
end
