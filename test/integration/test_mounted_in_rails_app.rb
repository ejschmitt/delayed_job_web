require 'test_helper'
require 'support/rails_app'
require 'support/delayed_job_fake'

class TestMountedInRailsApp < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    RailsApp
  end

  # basic smoke test all the tabs
  %w(overview enqueued working pending failed stats).each do |tab|
    define_method :"test_#{tab}" do
      get "/delayed_job/#{tab}"
      assert last_response.ok?, "Received bad response: #{last_response.inspect}"
    end
  end
end
