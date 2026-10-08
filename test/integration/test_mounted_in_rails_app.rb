require 'test_helper'
require 'support/rails_app'
require 'support/delayed_job_fake'

class TestMountedInRailsApp < MiniTest::Test
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

  %w(enqueued working pending failed).each do |tab|
    ["#{tab}.poll", "#{tab}/1.poll"].each do |path|
      define_method :"test_poll_#{path.tr('/.', '_')}" do
        get "/delayed_job/#{path}"

        assert last_response.ok?, "Received bad response: #{last_response.inspect}"
        assert_includes last_response.body, "Showing 0 to 20 of 0"
        refute_includes last_response.body, '<html'
      end
    end
  end

  %w(overview stats).each do |tab|
    define_method :"test_poll_#{tab}" do
      get "/delayed_job/#{tab}.poll"

      assert last_response.ok?, "Received bad response: #{last_response.inspect}"
      assert_includes last_response.body, 'Last Updated:'
      refute_includes last_response.body, '<html'
    end
  end
end
