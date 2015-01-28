Gem::Specification.new do |gem|
  gem.name        = "delayed_job_web"
  gem.version     = "1.2.10"
  gem.author      = "Erick Schmitt"
  gem.email       = "ejschmitt@gmail.com"
  gem.homepage    = "https://github.com/ejschmitt/delayed_job_web"
  gem.summary     = "Web interface for delayed_job inspired by resque"
  gem.description = gem.summary
  gem.license     = "MIT"

  gem.executables = ["delayed_job_web"]

  gem.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "delayed_job_web.gemspec"
  ] + %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(lib|test|bin)} }

  gem.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]

  gem.add_runtime_dependency "sinatra",      [">= 1.4.4"]
  gem.add_runtime_dependency "activerecord", ["> 3.0.0"]
  gem.add_runtime_dependency "delayed_job",  ["> 2.0.3"]

  gem.add_development_dependency "minitest",  ["~> 4.2"]
  gem.add_development_dependency "rack-test", ["~> 0.6"]
  gem.add_development_dependency "rails",     ["~> 4.0"]
end
