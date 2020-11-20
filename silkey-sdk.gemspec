# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'silkey/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.6'
  spec.name = 'silkey-sdk'
  spec.version = Silkey::VERSION
  spec.authors = ['silkey.io']
  spec.email = ['dariusz@silkey.io']

  spec.summary = 'Silkey SDK for Ruby.'
  spec.homepage = 'https://github.com/Silkey-Team/ruby-sdk'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against ' \
  #     'public gem pushes.'
  # end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'activesupport', '~> 6.0'
  spec.add_dependency 'jwt', '~> 2.2.2'
  spec.add_dependency 'eth', '~> 0.4.12'
  spec.add_dependency 'ethereum.rb', '~> 2.5'
  spec.add_dependency 'virtus', '~> 1.0'
  spec.add_dependency 'virtus_convert', '~> 0.1'
  spec.add_development_dependency 'rdoc', '~> 6.2', '>= 6.2.1'
  spec.add_development_dependency 'yard', '~> 0.9.25'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'factory_bot', '~> 6.1'
  spec.add_development_dependency 'pry', '~> 0.13'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.3'
  spec.add_development_dependency 'rubocop-performance', '~> 1.8'
end
