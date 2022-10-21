# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.add_development_dependency 'minitest',  ['~> 5.1']
  gem.add_development_dependency 'rack-test', ['~> 2.0']
  gem.add_development_dependency 'rails',     ['~> 7.0']
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-minitest'
  gem.add_development_dependency 'rubocop-ordered_methods'
  gem.add_development_dependency 'rubocop-performance'
  gem.add_development_dependency 'rubocop-rails'
  gem.add_development_dependency 'rubocop-rake'

  gem.add_runtime_dependency 'activerecord',    ['> 3.0.0']
  gem.add_runtime_dependency 'delayed_job',     ['> 2.0.3']
  gem.add_runtime_dependency 'rack-protection', ['>= 1.5.5']
  gem.add_runtime_dependency 'sinatra',         ['>= 1.4.4']

  gem.authors     = ['Erick Schmitt', 'Martin Streicher']
  gem.description = 'An engine to provide a web interface for delayed_job'
  gem.email       = ['ejschmitt@gmail.com', 'martin.streicher@gadget.consulting']
  gem.executables = ['delayed_job_web']

  gem.extra_rdoc_files = [
    'LICENSE.txt',
    'README.markdown'
  ]

  gem.files = [
    'Gemfile',
    'LICENSE.txt',
    'README.markdown',
    'Rakefile',
    'delayed_job_web.gemspec'
  ] + `git ls-files`.split("\n").grep(/^(lib|test|bin)/)

  gem.homepage    = 'https://github.com/martinstreicher/delayed_job_web'
  gem.license     = 'MIT'
  gem.metadata['rubygems_mfa_required'] = 'true'
  gem.name        = 'delayed_job_web'
  gem.summary     = 'Web interface for delayed_job'
  gem.version     = '1.5.0'
end
