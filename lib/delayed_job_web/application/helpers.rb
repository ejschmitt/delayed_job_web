# frozen_string_literal: true

module Helpers
  def csrf_token
    # Set up by Rack::Protection
    session[:csrf]
  end

  def csrf_token_tag
    # If csrf_token is nil, and we submit a blank string authenticity_token
    # param, Rack::Protection will fail.
    "<input type='hidden' name='authenticity_token' value='#{h csrf_token}'>" if csrf_token
  end

  def current_page
    url_path request.path_info.sub('/', '')
  end

  def datetime_with_seconds(time)
    time&.strftime('%Y-%m-%d %H:%M:%S')
  end

  def delayed_job
    Delayed::Job
  rescue StandardError
    false
  end

  def delayed_jobs(type, queues = [])
    rel = delayed_job

    rel =
      case type
      when :working
        rel.where('locked_at IS NOT NULL AND failed_at IS NULL')
      when :failed
        rel.where.not(last_error: nil)
      when :pending
        rel.where(attempts: 0, locked_at: nil)
      else
        rel
      end

    rel = rel.where(queue: queues) unless queues.empty?

    rel
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def partial(template, local_vars = {})
    @partial = true
    erb(template.to_sym, { layout: false }, local_vars)
  ensure
    @partial = false
  end

  def path_prefix
    request.env['SCRIPT_NAME']
  end

  def per_page
    params[:per_page].to_i.positive? ? params[:per_page].to_i : 20
  end

  def poll
    text =
      if @polling
        "Last Updated: #{Time.zone.now.strftime('%H:%M:%S')}"
      else
        "<a href='#{u("#{request.path_info}.poll")}' rel='poll'>Live Poll</a>"
      end
    "<p class='poll'>#{text}</p>"
  end

  def queue_path(queue)
    with_queue(queue) do
      url_path(:overview)
    end
  end

  def show_for_polling(page)
    content_type 'text/html'
    @polling = true
    # show(page.to_sym, false).gsub(/\s{1,}/, ' ')
    @jobs = delayed_jobs(page.to_sym, @queues)
    erb(page.to_sym, { layout: false })
  end

  def start
    params[:start].to_i
  end

  def tabs
    [
      { name: 'Overview', path: '/overview' },
      { name: 'Enqueued', path: '/enqueued' },
      { name: 'Working',  path: '/working' },
      { name: 'Pending',  path: '/pending' },
      { name: 'Failed',   path: '/failed' },
      { name: 'Workers',  path: '/workers' },
      { name: 'Stats',    path: '/stats' }
    ]
  end

  def url_path(*path_parts)
    url = [path_prefix, path_parts].join('/').squeeze('/')
    url += "?queues=#{CGI.escape(@queues.join(','))}" unless @queues.empty?
    url
  end

  alias u url_path

  def with_queue(queue)
    aux_queues = @queues
    @queues    = Array(queue)
    result     = yield
    @queues    = aux_queues
    result
  end
end
