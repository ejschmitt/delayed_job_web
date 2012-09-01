require 'helper'
require 'rack/test'
require 'delayed_job_web/application/app'
require 'mongo_definitions'

ENV['RACK_ENV'] = 'test'

class TestDelayedJobWebMongo < Test::Unit::TestCase
  include Rack::Test::Methods
  def app
    DelayedJobWeb.new
  end

  def should_respond_with_success
    assert last_response.ok?, last_response.errors
  end

  # basic smoke test all the tabs
  %w(overview enqueued working pending failed stats).each do |tab|
    should "mongo get '/#{tab}'" do
      get "/#{tab}"
      should_respond_with_success
    end
  end
end
