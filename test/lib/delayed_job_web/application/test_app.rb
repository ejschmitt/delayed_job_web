require 'test_helper'
require 'support/delayed_job_fake'
require 'delayed_job_web/application/app'

class TestDelayedJobWeb < Minitest::Test

  include Rack::Test::Methods

  PollingJob = Struct.new(:id, :created_at, :queue, :priority, :attempts,
                         :handler, :last_error, :run_at, :locked_at,
                         :locked_by, :failed_at)

  class PollingJobs < Array
    def where(criteria)
      self.class.new(select { |job| Array(criteria.fetch(:queue)).include?(job.queue) })
    end

    def order(*)
      self.class.new(sort_by { |job| [job.created_at, job.id] }.reverse)
    end

    def offset(start)
      self.class.new(drop(start))
    end

    def limit(count)
      self.class.new(first(count))
    end
  end

  def app
    DelayedJobWeb
  end

  def test_requeue_failed
    where = lambda { |criteria|
      assert_equal criteria, 'last_error IS NOT NULL'

      Minitest::Mock.new.expect(:update_all, nil, run_at: time, failed_at: nil)
    }

    Time.stub(:now, time) do
      Delayed::Job.stub(:where, where) do
        post "/requeue/failed", request_data, rack_env

        assert_equal 302, last_response.status
      end
    end
  end

  def test_requeue_pending
    where = lambda { |criteria|
      assert_equal criteria, { attempts: 0, locked_at: nil }
      Minitest::Mock.new.expect(:update_all, nil, run_at: time, failed_at: nil)
    }

    Time.stub(:now, time) do
      Delayed::Job.stub(:where, where) do
        post "/requeue/pending", request_data, rack_env
        assert_equal 302, last_response.status
      end
    end
  end

  def test_requeue_pending_with_requeue_pending_disallowed
    app.set(:allow_requeue_pending, false)

    where = lambda { |criteria|
      raise 'should not be called'
    }

    Time.stub(:now, time) do
      Delayed::Job.stub(:where, where) do
        post "/requeue/pending", request_data, rack_env
        assert_equal 302, last_response.status
      end
    end
  end

  def test_requeue_id
    find = lambda { |id|
      assert_equal id, '1'
      Minitest::Mock.new.expect(:update, nil, run_at: time, failed_at: nil)
    }

    Time.stub(:now, time) do
      Delayed::Job.stub(:find, find) do
        post "/requeue/1", request_data, rack_env
        assert 302, last_response.status
      end
    end
  end

  def test_poll_enqueued_preserves_filtered_pagination
    jobs = PollingJobs.new([
      polling_job(1, 'alpha', 1), polling_job(2, 'alpha', 2),
      polling_job(3, 'alpha', 2), polling_job(4, 'alpha', 3),
      polling_job(5, 'alpha', 4), polling_job(6, 'beta', 5)
    ])

    Delayed::Job.stub(:where, lambda { |criteria| jobs.where(criteria) }) do
      ['/enqueued', '/enqueued.poll'].each do |path|
        get path, { queues: ' alpha,alpha ', start: 1, per_page: 2 }, rack_env

        assert last_response.ok?, "Received bad response: #{last_response.inspect}"
        assert_includes last_response.body, 'Showing 1 to 3 of 5 enqueued jobs.'
        assert_equal ['4', '3'], last_response.body.scan(/<a name="(\d+)"><\/a>/).flatten
        assert_includes last_response.body, '/requeue/4?queues=alpha'
        assert_includes last_response.body, 'start=3'
        refute_includes last_response.body, '<html' if path.end_with?('.poll')
      end
    end
  end

  def test_poll_pending_respects_requeue_setting
    jobs = PollingJobs.new([polling_job(1, 'alpha', 1)])
    original_setting = app.allow_requeue_pending

    Delayed::Job.stub(:where, jobs) do
      [true, false].each do |allowed|
        app.set(:allow_requeue_pending, allowed)
        get '/pending.poll', {}, rack_env

        assert last_response.ok?, "Received bad response: #{last_response.inspect}"
        assert_equal allowed, last_response.body.include?('Enqueue All Immediately')
        assert_includes last_response.body, 'Showing 0 to 20 of 1 pending jobs.'
        assert_equal ['1'], last_response.body.scan(/<a name="(\d+)"><\/a>/).flatten
      end
    end
  ensure
    app.set(:allow_requeue_pending, original_setting)
  end

  def time
    @time ||= Time.now
  end

  private

  def polling_job(id, queue, created_at)
    PollingJob.new(id, created_at, queue, 0, 0, 'job', nil, nil, nil, nil, nil)
  end

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
