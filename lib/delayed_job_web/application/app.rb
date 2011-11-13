require 'sinatra'
require 'delayed_job'

class DelayedJobWeb < Sinatra::Base

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
    begin
      Delayed::Job
    rescue
      false
    end
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
