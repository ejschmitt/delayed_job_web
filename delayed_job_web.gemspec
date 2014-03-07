# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "delayed_job_web"
  s.version = "1.2.5"

  s.authors = ["Erick Schmitt"]
  s.date = "2014-01-29"
  s.description = "Web interface for delayed_job inspired by resque"
  s.email = "ejschmitt@gmail.com"
  s.executables = ["delayed_job_web"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "bin/delayed_job_web",
    "delayed_job_web.gemspec",
    "lib/delayed_job_web.rb",
    "lib/delayed_job_web/application/app.rb",
    "lib/delayed_job_web/application/public/images/poll.png",
    "lib/delayed_job_web/application/public/javascripts/application.js",
    "lib/delayed_job_web/application/public/javascripts/jquery-1.7.1.min.js",
    "lib/delayed_job_web/application/public/javascripts/jquery.relatize_date.js",
    "lib/delayed_job_web/application/public/stylesheets/reset.css",
    "lib/delayed_job_web/application/public/stylesheets/style.css",
    "lib/delayed_job_web/application/views/enqueued.erb",
    "lib/delayed_job_web/application/views/error.erb",
    "lib/delayed_job_web/application/views/failed.erb",
    "lib/delayed_job_web/application/views/job.erb",
    "lib/delayed_job_web/application/views/layout.erb",
    "lib/delayed_job_web/application/views/next_more.erb",
    "lib/delayed_job_web/application/views/overview.erb",
    "lib/delayed_job_web/application/views/pending.erb",
    "lib/delayed_job_web/application/views/stats.erb",
    "lib/delayed_job_web/application/views/working.erb",
    "test/helper.rb",
    "test/test_delayed_job_web.rb"
  ]
  s.homepage = "http://github.com/ejschmitt/delayed_job_web"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.summary = "Web interface for delayed_job"

  s.add_runtime_dependency(%q<sinatra>, [">= 1.4.4"])
  s.add_runtime_dependency(%q<activerecord>, ["> 3.0.0"])
  s.add_runtime_dependency(%q<delayed_job>, ["> 2.0.3"])
  s.add_development_dependency(%q<shoulda>, [">= 0"])
  s.add_development_dependency(%q<rack-test>, [">= 0"])
end

