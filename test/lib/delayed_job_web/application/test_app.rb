require 'test_helper'
require 'support/delayed_job_fake'
require 'delayed_job_web/application/app'

class TestDelayedJobWeb < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    DelayedJobWeb
  end

  def test_requeue_all

    dataset = Minitest::Mock.new
    where = lambda { | criteria |
      criteria.must_equal 'last_error IS NOT NULL'
      dataset
    }

    dataset.expect(:update_all, nil, [:run_at => time, :failed_at => nil])

    Time.stub(:now, time) do
      Delayed::Job.stub(:where, where) do
        post "/requeue/all", request_data, rack_env
        last_response.status.must_equal 302
      end
    end

    dataset.verify

  end

  def test_requeue_id
    job = Minitest::Mock.new
    job.expect(:update_attributes, nil, [:run_at => time, :failed_at => nil])

    find = lambda { | id |
      id.must_equal "1"
      job
    }

    Time.stub(:now, time) do
      Delayed::Job.stub(:find, find) do
        post "/requeue/1", request_data, rack_env
        last_response.status.must_equal 302
      end
    end

    job.verify
  end

  private

  def time
    @time ||= Time.now
  end

  def rack_env
    {'rack.session' => {:csrf => "123"}}
  end

  def request_data
    {"authenticity_token" => "123"}
  end

end
