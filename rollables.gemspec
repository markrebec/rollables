Gem::Specification.new do |s|
  s.name        = 'rollables'
  s.version     = '0.0.1'
  s.date        = '2012-01-04'
  s.summary     = "Rollable dice for Ruby"
  s.description = "Rollable dice for Ruby"
  s.authors     = ["Mark Rebec"]
  s.email       = 'mark@markrebec.com'
  s.files       = ["lib/array.rb", "lib/object.rb", "lib/rollables.rb", "lib/rollables/die.rb", "lib/rollables/die_notation.rb", "lib/rollables/dice.rb"]
  s.homepage    = 'http://github.com/markrebec/rollables'

  s.add_development_dependency 'rspec'
end
