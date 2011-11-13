require 'helper'
require 'rack/test'
require 'delayed_job_web/application/app'
ENV['RACK_ENV'] = 'test'

class TestDelayedJobWeb < Test::Unit::TestCase
  include Rack::Test::Methods
  def app
    DelayedJobWeb.new
  end

  should "get '/'" do
    get '/'
    assert last_response.body.include?('Overview')
  end
end
