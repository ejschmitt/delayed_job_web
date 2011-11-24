require 'helper'
require 'rack/test'
require 'delayed_job_web/application/app'
ENV['RACK_ENV'] = 'test'

class Delayed::Job
  class DelayedJobFake < Array
    # fake out arel
    def order(*args)
      DelayedJobFake.new
    end

    def offset(*args)
      DelayedJobFake.new
    end

    def limit(*args)
      DelayedJobFake.new
    end
  end

  def self.where(*args)
    DelayedJobFake.new
  end

  def self.count(*args)
    0
  end
end

class TestDelayedJobWeb < Test::Unit::TestCase
  include Rack::Test::Methods
  def app
    DelayedJobWeb.new
  end

  def should_respond_with_success
    assert last_response.ok?, last_response.errors
  end

  # basic smoke test all the tabs
  %w(overview enqueued working pending failed stats).each do |tab|
    should "get '/#{tab}'" do
      get "/#{tab}"
      should_respond_with_success
    end
  end
end
