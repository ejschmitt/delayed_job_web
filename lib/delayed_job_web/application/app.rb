require 'sinatra'
require 'active_support'
require 'active_record'
require 'delayed_job'
require 'haml'

configure do
  puts "Configuring delayed_job_web"
  Delayed::Worker.backend = :active_record
  config = YAML::load(File.open('config/database.yml'))
  environment = Sinatra::Application.environment.to_s
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(
    SHARED_DATABASE_URL || config[environment]
  )
end

class DelayedJobWeb < Sinatra::Base

  set :static, true                             # set up static file routing
  set :public_folder, File.expand_path('..', __FILE__) # set up the static dir (with images/js/css inside)
  set :views,  File.expand_path('../views', __FILE__) # set up the views dir
  set :haml, { :format => :html5 }
  set :root, File.dirname(__FILE__)

  def url_path(*path_parts)
    [ path_prefix, path_parts ].join("/").squeeze('/')
  end
  alias_method :u, :url_path

  def path_prefix
    request.env['SCRIPT_NAME']
  end

  def tabs
    [
      {name: 'Overview', path: ''},
      {name: 'Enqueued', path: '/enqueued'},
      {name: 'Working', path: '/working'},
      {name: 'Pending', path: '/pending'},
      {name: 'Failed', path: '/failed'},
      {name: 'Stats', path: '/stats'}
    ]
  end

  def delayed_job
    begin
      Delayed::Job
    rescue
      false
    end
  end

  get '/' do
    if delayed_job
      @job_count = delayed_job.count
      @working_count = delayed_jobs(:working).count
      @failed_count = delayed_jobs(:failed).count
      @pending_count = delayed_jobs(:pending).count
      haml :index
    else
      @message = "Unable to connected to Delayed::Job database"
      haml :error
    end
  end

  get '/enqueued' do
    @jobs = delayed_job.all
    haml :enqueued
  end

  get '/working' do
    @jobs = delayed_jobs(:working)
    haml :working
  end

  get '/pending' do
    @jobs = delayed_jobs(:pending)
    haml :pending
  end

  get '/failed' do
    @jobs = delayed_jobs(:failed)
    haml :failed
  end

  get '/stats' do
    haml :stats
  end

  def delayed_jobs(type)
    case type
    when :working
      delayed_job.where('locked_at is not null')
    when :failed
      delayed_job.where('last_error is not null')
    when :pending
      delayed_job.where(:attempts => 0)
    end
  end

  def partial(template, local_vars = {})
    @partial = true
    haml(template.to_sym, {:layout => false}, local_vars)
  ensure
    @partial = false
  end

end

# Run the app!
#
# puts "Hello, you're running delayed_job_web"
# DelayedJobWeb.run!
