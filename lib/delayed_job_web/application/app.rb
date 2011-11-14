require 'sinatra'
require 'active_support'
require 'active_record'
require 'delayed_job'


class DelayedJobWeb < Sinatra::Base
  configure do
    Delayed::Worker.backend = :active_record
    config = YAML::load(File.open('config/database.yml'))
    environment = Sinatra::Application.environment.to_s
    ActiveRecord::Base.logger = Logger.new($stdout)
    ActiveRecord::Base.establish_connection(
      config[environment]
    )
  end

  set :static, true                             # set up static file routing
  set :public_folder, File.expand_path('..', __FILE__) # set up the static dir (with images/js/css inside)
  set :views,  File.expand_path('../views', __FILE__) # set up the views dir
  set :haml, { :format => :html5 }

  def tabs
    [
      {name: 'Overview', path: '/'},
      {name: 'Working', path: '/working'},
      {name: 'Failed', path: '/failed'}
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
      @working_count = delayed_job.where(:attempts => 0).count
      @failed_count = delayed_job.where('last_error is not null').count
      haml :index
    else
      @message = "Unable to connected to Delayed::Job database"
      haml :error
    end
  end

  get '/working' do
    haml :working
  end

  get '/failed' do
    @failed_jobs = delayed_job.where('last_error is not null')
    haml :failed
  end

end

# Run the app!
#
puts "Hello, you're running delayed_job_web"
DelayedJobWeb.run!
