Gem::Specification.new do |s|
  s.name        = 'bones'
  s.version     = '0.0.1'
  s.date        = '2012-01-04'
  s.summary     = "Rollable dice for Ruby"
  s.description = "Rollable dice for Ruby"
  s.authors     = ["Mark Rebec"]
  s.email       = 'mark@markrebec.com'
  s.files       = ["lib/array.rb", "lib/bones.rb", "lib/bones/die.rb", "lib/bones/dice.rb"]
  s.homepage    = 'http://github.com/markrebec/bones'

  s.add_development_dependency 'rspec'
end
