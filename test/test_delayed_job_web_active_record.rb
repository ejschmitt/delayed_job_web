require 'helper'
require 'rack/test'
require 'delayed_job_web/application/app'
require 'active_record_definitions'

ENV['RACK_ENV'] = 'test'


class TestDelayedJobWebActiveRecord < Test::Unit::TestCase
  include Rack::Test::Methods
  def app
    DelayedJobWeb.new
  end

  def should_respond_with_success
    assert last_response.ok?, last_response.errors
  end

  # basic smoke test all the tabs
  %w(overview enqueued working pending failed stats).each do |tab|
    should "active_record get '/#{tab}'" do
      get "/#{tab}"
      should_respond_with_success
    end
  end
end
