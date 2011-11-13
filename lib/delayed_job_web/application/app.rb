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
      {name: 'Blah', path: '/blah'}
    ]
  end

  def delayed_job
    Delayed::Job
  end

  get '/' do
    if delayed_job
      haml :index
    else
      @message = "Unable to connected to Delayed::Job database"
      haml :error
    end
  end

end

# Run the app!
#
puts "Hello, you're running delayed_job_web"
DelayedJobWeb.run!
