$LOAD_PATH.push File.expand_path('lib', __dir__)
require "delayed_paperclip_apartment/version"

Gem::Specification.new do |s|
  s.name        = %q{delayed_paperclip_apartment}
  s.version     = DelayedPaperclipApartment::VERSION

  s.authors     = ["Jesse Storimer", "Bert Goethals", "James Gifford", "Scott Carleton", "Alek Niemczyk"]
  s.summary     = %q{A fork of delayed_paperclip with Apartment integration}
  s.description = %q{A fork of delayed_paperclip with Apartment integration}
  s.email       = %w{alek@rubylogic.pl}
  s.homepage    = %q{https://github.com/ruby-logic/delayed_paperclip_apartment}

  s.required_ruby_version = ">= 2.0.0"

  s.add_dependency 'paperclip', [">= 3.3"]
  s.add_dependency 'activejob', ">= 4.2"
  s.add_dependency 'apartment'

  s.add_development_dependency 'mocha'
  s.add_development_dependency "rspec", '< 3.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rake', '~> 10.5.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'railties'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
end
