# frozen_string_literal: true

require_relative 'lib/daffy_lib/version'

Gem::Specification.new do |spec|
  spec.name          = "daffy_lib"
  spec.version       = DaffyLib::VERSION
  spec.authors       = ["Benoît Jeaurond, Weiyun Lu"]
  spec.email         = ["weiyun.lu@arioplatform.com"]

  spec.summary       = 'A library for caching encryptor'
  spec.homepage      = 'https://github.com/Zetatango/daffy_lib'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'attr_encrypted'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-collection_matchers'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubocop_runner'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'timecop'

  spec.add_dependency 'porky_lib'
  spec.add_dependency 'rails'
  spec.add_dependency 'redis'
end
