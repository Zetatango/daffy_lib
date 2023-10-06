# frozen_string_literal: true

require_relative 'lib/daffy_lib/version'

Gem::Specification.new do |spec|
  spec.name          = "daffy_lib"
  spec.version       = DaffyLib::VERSION
  spec.authors       = ["Benoît Jeaurond, Weiyun Lu"]
  spec.email         = ["weiyun.lu@arioplatform.com"]

  spec.summary       = 'A library for caching encryptor'
  spec.homepage      = 'https://github.com/Zetatango/daffy_lib'

  spec.required_ruby_version = '>= 3.2.2'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'porky_lib'
  spec.add_dependency 'rails'
  spec.add_dependency 'redis'
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
