# class DelayedJobWe
#   configure :development do
#     puts "Configuring delayed_job_web"
#     Delayed::Worker.backend = :active_record
#     config = YAML::load(File.open('config/database.yml'))
#     environment = Sinatra::Application.environment.to_s
#     ActiveRecord::Base.logger = Logger.new($stdout)
#     ActiveRecord::Base.establish_connection(
#       config[environment]
#     )
#   end

#   configure :production do
#     puts "Configuring delayed_job_web"
#     db = ENV["DATABASE_URL"]
#     if db.match(/postgres:\/\/(.*):(.*)@(.*)\/(.*)/)
#       username = $1
#       password = $2
#       hostname = $3
#       database = $4

#       ActiveRecord::Base.establish_connection(
#         :adapter  => 'postgresql',
#         :host     => hostname,
#         :username => username,
#         :password => password,
#         :database => database
#       )
#     end
#   end
# end
