Gem::Specification.new do |s|
  s.name        = 'rubygems-mirror'
  s.version     = '1.0.1'
  s.summary     = "This is an update to the old `gem mirror` command"
  s.description = "This is an update to the old `gem mirror` command. It uses net/http/persistent\nand threads to grab the mirror set a little faster than the original.\nEventually it will replace `gem mirror` completely. Right now the API is not\ncompletely stable (it will change several times before release), however, I\nwill maintain stability in master."
  s.authors     = ["James Tucker"]
  s.email       = 'raggi@rubyforge.org'
  s.homepage    = 'http://github.com/rubygems/rubygems-mirror'

  s.files       = `git ls-files bin/ lib/`.split("\n") + %w[CHANGELOG.rdoc README.rdoc]

  s.add_dependency 'net-http-persistent', '>= 2.1'
end
