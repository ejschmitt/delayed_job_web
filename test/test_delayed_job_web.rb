require 'helper'
require 'rack/test'
require 'delayed_job_web/application/app'

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
  %w(active_record mongo).each do |db|
    require "#{db}_definitions"
    %w(overview enqueued working pending failed stats).each do |tab|
      should "get '/#{tab}' '#{db} version'" do
        get "/#{tab}"
        should_respond_with_success
      end
    end
  end
end
