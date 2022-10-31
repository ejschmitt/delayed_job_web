# frozen_string_literal: true

require 'sinatra/base'
require 'active_support'
require 'active_record'
require 'delayed_job'
require_relative 'helpers'

class DelayedJobWeb < Sinatra::Base
  include Helpers

  set :root, File.dirname(__FILE__)
  set :static, true
  set :public_folder, File.expand_path('public', __dir__)
  set :views, File.expand_path('views', __dir__)

  set :allow_requeue_pending, true

  # Enable sessions so we can use CSRF protection
  enable :sessions

  set :protection,
    # Various session protections
    session:  true,
    # Various non-default Rack::Protection options
    use:      [
      # Prevent destructive actions without a valid CSRF auth token
      :authenticity_token,
      # Prevent destructive actions with remote referrers
      :remote_referrer
    ],
    # Deny the request, don't clear the session
    reaction: :deny

  before do
    @queues = (params[:queues] || '').split(',').map(&:strip).uniq.compact
  end

  #
  # GET routes

  get '/job/:id' do
    @job = delayed_job.find_by(id: params[:id])

    if @job.nil?
      redirect back
      return
    end

    erb :jobs
  end

  get '/overview' do
    if delayed_job
      erb :overview
    else
      @message = 'Unable to connected to Delayed::Job database'
      erb :error
    end
  end

  get '/workers' do
    @workers = ::System::Worker.all
    erb :workers
  end

  get '/stats' do
    erb :stats
  end

  %w[enqueued working pending failed].each do |page|
    get "/#{page}" do
      @jobs = delayed_jobs(
        page.to_sym,
        @queues
      ).order('created_at desc, id desc').offset(start).limit(per_page)

      @all_jobs = delayed_jobs(page.to_sym, @queues)
      @allow_requeue_pending = settings.allow_requeue_pending
      erb page.to_sym
    end
  end

  get '/?' do
    redirect u(:overview)
  end

  %w[overview enqueued working pending failed stats].each do |page|
    get "/#{page}.poll" do
      show_for_polling(page)
    end

    get "/#{page}/:id.poll" do
      show_for_polling(page)
    end
  end

  #
  # POST routes

  post '/remove/:id' do
    delayed_job.find(params[:id]).delete
    redirect back
  end

  post '/requeue/pending' do
    if settings.allow_requeue_pending
      delayed_jobs(:pending, @queues).update_all(
        run_at:    Time.zone.now,
        failed_at: nil
      )
    end

    redirect back
  end

  post '/requeue/failed' do
    delayed_jobs(:failed, @queues).update_all(run_at: Time.zone.now, failed_at: nil)

    redirect back
  end

  post '/requeue/:id' do
    job = delayed_job.find(params[:id])
    job.update(run_at: Time.zone.now, failed_at: nil)
    redirect back
  end

  post '/reload/:id' do
    job = delayed_job.find(params[:id])
    job.update(
      run_at:     Time.zone.now,
      failed_at:  nil,
      locked_by:  nil,
      locked_at:  nil,
      last_error: nil,
      attempts:   0
    )
    redirect back
  end

  post '/failed/clear' do
    delayed_jobs(:failed, @queues).delete_all
    redirect u('failed')
  end
end
