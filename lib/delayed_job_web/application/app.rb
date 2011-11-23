require 'sinatra'
require 'active_support'
require 'active_record'
require 'delayed_job'
require 'haml'

configure :development do
  puts "Configuring delayed_job_web"
  Delayed::Worker.backend = :active_record
  config = YAML::load(File.open('config/database.yml'))
  environment = Sinatra::Application.environment.to_s
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(
    config[environment]
  )
end

configure :production do
  puts "Configuring delayed_job_web"
  db = ENV["DATABASE_URL"]
  if db.match(/postgres:\/\/(.*):(.*)@(.*)\/(.*)/)
    username = $1
    password = $2
    hostname = $3
    database = $4

    ActiveRecord::Base.establish_connection(
      :adapter  => 'postgresql',
      :host     => hostname,
      :username => username,
      :password => password,
      :database => database
    )
  end
end

class DelayedJobWeb < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public,  File.expand_path('../public', __FILE__)
  set :views,  File.expand_path('../views', __FILE__)
  set :haml, { :format => :html5 }

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

  get "/remove/:id" do
    delayed_job.find(params[:id]).delete
    redirect back
  end

  get "/requeue/:id" do
    job = delayed_job.find(params[:id])
    job.run_at = Time.now
    job.save
    redirect back
  end

  post "/failed/clear" do
    delayed_job.destroy_all(delayed_job_sql(:failed))
    redirect u('failed')
  end

  post "/requeue/all" do
    delayed_jobs(:failed).each{|dj| dj.run_at = Time.now; dj.save}
    redirect back
  end

  def delayed_jobs(type)
    delayed_job.where(delayed_job_sql(type))
  end

  def delayed_job_sql(type)
    case type
    when :working
      'locked_at is not null'
    when :failed
      'last_error is not null'
    when :pending
      'attempts = 0'
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
