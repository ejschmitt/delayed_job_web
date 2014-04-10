require 'test_helper'
require 'support/delayed_job_fake'
require 'delayed_job_web/application/app'

describe DelayedJobWeb do

  include Rack::Test::Methods

  let(:app) { DelayedJobWeb }
  let(:rack_env) { {'rack.session' => {:csrf => "123"}} }
  let(:request_data) { {"authenticity_token" => "123"} }

  describe '/requeue/all' do

    let(:time) { Time.now }
    let(:dataset) { Minitest::Mock.new }
    let(:where) do
      lambda { | criteria |
        criteria.must_equal 'last_error IS NOT NULL'
        dataset
      }
    end

    before do
      dataset.expect(:update_all, nil, [:run_at => time, :failed_at => nil])
    end

    it 'requeues all jobs that have errors' do

      Time.stub(:now, time) do
        Delayed::Job.stub(:where, where) do
          post "/requeue/all", request_data, rack_env
          last_response.status.must_equal 302
        end
      end

      dataset.verify
    end
  end

  describe '/requeue/:id' do

    let(:time) { Time.now }
    let(:job) { Minitest::Mock.new }
    let(:find) do
      lambda { | id |
        id.must_equal "1"
        job
      }
    end

    before do
      job.expect(:update_attributes, nil, [:run_at => time, :failed_at => nil])
    end

    it 'requeues the specified job' do

      Time.stub(:now, time) do
        Delayed::Job.stub(:find, find) do
          post "/requeue/1", request_data, rack_env
          last_response.status.must_equal 302
        end
      end

      job.verify

    end

  end
end
