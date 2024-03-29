# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epf_downloader/version'

Gem::Specification.new do |spec|
  spec.name          = 'epf_downloader'
  spec.version       = EpfDownloader::VERSION
  spec.authors       = ['HelloNeu']
  spec.email         = ['info@helloneu.de']
  spec.summary       = 'Apple EPF Downloader'
  spec.description   = 'Apple EPF Downloader'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'timecop'

  spec.add_dependency 'curb'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday'
  spec.add_dependency 'ruby-progressbar'

end
