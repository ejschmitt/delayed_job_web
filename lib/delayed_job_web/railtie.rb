# Sinatra will automatically use Rails sessions if mounted within a Rails app.
#
# If you enable sessions in a Sinatra app, and then mount it in a Rails 4 app,
# Rack::Session will blow up because ActionDispatch::Request::Session does not
# implement #each.

DelayedJobWeb.disable :sessions
