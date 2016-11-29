require 'sinatra/base'
require 'active_support'
require 'active_record'
require 'delayed_job'

class HerokuPlatform
  def self.heroku_token
    ENV['DJWEB_HEROKU_TOKEN']
  end

  def self.heroku_app_name
    ENV['DJWEB_HEROKU_APP_NAME']
  end
  
  def self.monitor_zombies
    !!(heroku_token && heroku_app_name)
  end

  def self.heroku
    PlatformAPI.connect_oauth(heroku_token)
  end

  def self.dynos(refresh = false)
    @@dynos = nil if refresh
    @@dynos ||= heroku.dyno.list(heroku_app_name)
  end  
end

module Delayed
  class Job
    scope :locked_by_like, ->(id) { where("locked_by like ?", "%#{id}%") }
    scope :not_locked_by_like, ->(ids) { where(ids.map{|id| "locked_by not like '%#{id}%'"}.join(" and ")) }
  end

  class Worker
    def initialize(options={})
      # original code
      @quiet = options.has_key?(:quiet) ? options[:quiet] : true
      @failed_reserve_count = 0
      [:min_priority, :max_priority, :sleep_delay, :read_ahead, :queues, :exit_on_complete].each do |option|
        self.class.send("#{option}=", options[option]) if options.has_key?(option)
      end
      self.plugins.each { |klass| klass.new }      # inject dyno name/id in worker name to be stored in locked_by and we can link back jobs to workers

      # new code
      dyno_name = ENV['DYNO']
      if dyno_name && HerokuPlatform.monitor_zombies
        begin
          dyno_id = HerokuPlatform.dynos(true).find{|dyno| dyno["name"] == dyno_name}["id"]
          self.name = "dyno_name:#{dyno_name} dyno_id:#{dyno_id} pid:#{Process.pid}"
        rescue
          # couldn't get heroku dyno info, never mind fallback to default name (do nothing here)
          puts "Error getting dyno id"
        end
      end
    end
  end
end

class DelayedJobWeb < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public_folder, File.expand_path('../public', __FILE__)
  set :views, File.expand_path('../views', __FILE__)

  # Enable sessions so we can use CSRF protection
  enable :sessions

  set :protection,
    # Various session protections
    :session => true,
    # Various non-default Rack::Protection options
    :use => [
      # Prevent destructive actions without a valid CSRF auth token
      :authenticity_token,
      # Prevent destructive actions with remote referrers
      :remote_referrer
    ],
    # Deny the request, don't clear the session
    :reaction => :deny

  before do
    @queues = (params[:queues] || "").split(",").map{|queue| queue.strip}.uniq.compact
  end

  def current_page
    url_path request.path_info.sub('/','')
  end

  def start
    params[:start].to_i
  end

  def per_page
    20
  end

  def url_path(*path_parts)
    url = [ path_prefix, path_parts ].join("/").squeeze('/')
    url += "?queues=#{@queues.join(",")}" unless @queues.empty?
    url
  end

  alias_method :u, :url_path

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def path_prefix
    request.env['SCRIPT_NAME']
  end

  def tabs
    t = [
      {:name => 'Overview', :path => '/overview'},
      {:name => 'Enqueued', :path => '/enqueued'},
      {:name => 'Working', :path => '/working'},
      {:name => 'Pending', :path => '/pending'},
      {:name => 'Failed', :path => '/failed'},
      {:name => 'Stats', :path => '/stats'}
    ]
    t.insert(3, {:name => 'Heroku Zombies', :path => '/zombies'}) if HerokuPlatform.monitor_zombies
    t
  end

  def delayed_job
    begin
      Delayed::Job
    rescue
      false
    end
  end

  def csrf_token
    # Set up by Rack::Protection
    session[:csrf]
  end

  def csrf_token_tag
    # If csrf_token is nil, and we submit a blank string authenticity_token
    # param, Rack::Protection will fail.
    if csrf_token
      "<input type='hidden' name='authenticity_token' value='#{h csrf_token}'>"
    end
  end

  get '/overview' do
    if delayed_job
      erb :overview
    else
      @message = "Unable to connected to Delayed::Job database"
      erb :error
    end
  end

  get '/stats' do
    erb :stats
  end

  %w(enqueued working zombies pending failed).each do |page|
    get "/#{page}" do
      @jobs     = delayed_jobs(page.to_sym, @queues).order('created_at desc, id desc').offset(start).limit(per_page)
      @jobs     = @jobs.locked_by_like(params[:dyno_id]) if params[:dyno_id].present?
      @all_jobs = delayed_jobs(page.to_sym, @queues)
      @all_jobs = @all_jobs.locked_by_like(params[:dyno_id]) if params[:dyno_id].present?
      @dyno_name= params[:dyno_name] 
      erb page.to_sym
    end
  end

  post "/remove/:id" do
    delayed_job.find(params[:id]).delete
    redirect back
  end

  %w(pending failed).each do |page|
    post "/requeue/#{page}" do
      delayed_jobs(page.to_sym, @queues).update_all(:run_at => Time.now, :failed_at => nil)
      redirect back
    end
  end

  post "/requeue/:id" do
    job = delayed_job.find(params[:id])
    job.update_attributes(:run_at => Time.now, :failed_at => nil)
    redirect back
  end

  post "/reload/:id" do
    job = delayed_job.find(params[:id])
    job.update_attributes(:run_at => Time.now, :failed_at => nil, :locked_by => nil, :locked_at => nil, :last_error => nil, :attempts => 0)
    redirect back
  end

  post "/failed/clear" do
    delayed_jobs(:failed, @queues).delete_all
    redirect u('failed')
  end

  post "/refresh_heroku_dynos" do
    HerokuPlatform.dynos(true)
    redirect back
  end

  def delayed_jobs(type, queues = [])
    rel = delayed_job

    rel =
      case type
      when :working
        rel.where('locked_at IS NOT NULL')
      when :zombies
        rel.where("locked_at IS NOT NULL").not_locked_by_like(HerokuPlatform.dynos.select{|dyno| dyno["state"] == "up"}.map{|dyno| dyno['id']})
      when :failed
        rel.where('last_error IS NOT NULL')
      when :pending
        rel.where(:attempts => 0, :locked_at => nil)
      else
        rel
      end

    rel = rel.where(:queue => queues) unless queues.empty?

    rel
  end

  get "/?" do
    redirect u(:overview)
  end

  def partial(template, local_vars = {})
    @partial = true
    erb(template.to_sym, {:layout => false}, local_vars)
  ensure
    @partial = false
  end

  %w(overview enqueued working zombies pending failed stats) .each do |page|
    get "/#{page}.poll" do
      show_for_polling(page)
    end

    get "/#{page}/:id.poll" do
      show_for_polling(page)
    end
  end

  def poll
    if @polling
      text = "Last Updated: #{Time.now.strftime("%H:%M:%S")}"
    else
      text = "<a href='#{u(request.path_info + ".poll")}' rel='poll'>Live Poll</a>"
    end
    "<p class='poll'>#{text}</p>"
  end

  def show_for_polling(page)
    content_type "text/html"
    @polling = true
    # show(page.to_sym, false).gsub(/\s{1,}/, ' ')
    @jobs = delayed_jobs(page.to_sym, @queues)
    erb(page.to_sym, {:layout => false})
  end

end

# Run the app!
#
# puts "Hello, you're running delayed_job_web"
# DelayedJobWeb.run!
