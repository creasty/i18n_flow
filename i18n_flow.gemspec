lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i18n_flow/version'

Gem::Specification.new do |spec|
  spec.name          = 'i18n_flow'
  spec.version       = I18nFlow::VERSION
  spec.authors       = ['Yuki Iwanaga']
  spec.email         = ['yuki@creasty.com']

  spec.summary       = %q{Manage translation status in yaml file}
  spec.description   = %q{Manage translation status in yaml file}
  spec.homepage      = 'https://github.com/creasty/i18n_flow'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'psych', '>= 3.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'pry'
end
