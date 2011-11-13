require 'sinatra'

class DelayedJobWeb < Sinatra::Base

  set :static, true                             # set up static file routing
  set :public_folder, File.expand_path('..', __FILE__) # set up the static dir (with images/js/css inside)
  set :views,  File.expand_path('../views', __FILE__) # set up the views dir
  set :haml, { :format => :html5 }

  # Your "actions" go here…
  #
  get '/' do
    haml :index
  end

end

# Run the app!
#
puts "Hello, you're running your web app from a gem!"
DelayedJobWeb.run!
