# frozen_string_literal: true

require 'test_helper'
require 'support/delayed_job_fake'
require 'delayed_job_web/application/app'

class TestDelayedJobWeb < Minitest::Test
  include Rack::Test::Methods

  def app
    DelayedJobWeb
  end

  def test_requeue_failed
    where =
      lambda { |criteria|
        assert_equal('last_error IS NOT NULL', criteria)

        Minitest::Mock.new.expect(:update_all, nil, run_at: time, failed_at: nil)
      }

    Time.stub(:now, time) do
      Delayed::Job.stub(:where, where) do
        post '/requeue/failed', params: request_data, session: rack_env

        assert_equal 302, last_response.status
      end
    end
  end

  def test_requeue_pending
    where =
      lambda { |criteria|
        assert_equal({ attempts: 0, locked_at: nil }, criteria)
        Minitest::Mock.new.expect(:update_all, nil, run_at: time, failed_at: nil)
      }

    Time.stub(:now, time) do
      Delayed::Job.stub(:where, where) do
        post '/requeue/pending', params: request_data, session: rack_env
        assert_equal 302, last_response.status
      end
    end
  end

  def test_requeue_pending_with_requeue_pending_disallowed
    app.set(:allow_requeue_pending, false)

    where =
      lambda { |_criteria|
        raise 'should not be called'
      }

    Time.stub(:now, time) do
      Delayed::Job.stub(:where, where) do
        post '/requeue/pending', params: request_data, session: rack_env
        assert_equal 302, last_response.status
      end
    end
  end

  def test_requeue_id
    find =
      lambda { |id|
        assert_equal('1', id)
        Minitest::Mock.new.expect(:update, nil, run_at: time, failed_at: nil)
      }

    Time.stub(:now, time) do
      Delayed::Job.stub(:find, find) do
        post '/requeue/1', params: request_data, session: rack_env
        assert 302, last_response.status
      end
    end
  end

  def time
    @time ||= Time.zone.now
  end

  private

  def csrf_token
    @csrf_roken ||= Rack::Protection::AuthenticityToken.random_token
  end

  def rack_env
    { 'rack.session' => { csrf: csrf_token } }
  end

  def request_data
    { 'authenticity_token' => csrf_token }
  end
end
