delayed_job_web
===============

A [resque][0] inspired (read: stolen) interface for delayed_job.
This gem is written to work with rails 3 and 4 applications using
activerecord.

Some features:

* Easily view jobs enqueued, working, pending, and failed.
* Queue any single job. or all pending jobs, to run immediately.
* Remove a failed job, or easily remove all failed jobs.
* Watch delayed_job operation with live ajax polling.
* Filter delayed_jobs by queue name

The interface (yea, a ripoff of resque-web):

![Screen shot](http://dl.dropbox.com/u/1506097/Screenshots/delayed_job_web_1.png)


Quick Start For Rails 3 and 4 Applications
------------------------------------

Add the dependency to your Gemfile

```ruby
gem "delayed_job_web"
```

Install it...

```ruby
bundle
```

Add the following route to your application for accessing the interface,
and retrying failed jobs.

```ruby
match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
```

You probably want to password protect the interface, an easy way is to add something like this your config.ru file

```ruby
if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == 'username' && password == 'password'
  end
end
```

`delayed_job_web` runs as a Sinatra application within the rails application. Visit it at `/delayed_job`.

## Serving static assets

If you mount the app on another route, you may encounter the CSS not working anymore. To work around this you can leverage a special HTTP header. Install it, activate it and configure it -- see below.

### Apache

    XSendFile On
    XSendFilePath /path/to/shared/bundle

[`XSendFilePath`](https://tn123.org/mod_xsendfile/) white-lists a directory from which static files are allowed to be served. This should be at least the path to where delayed_job_web is installed.

Using Rails you'll have to set `config.action_dispatch.x_sendfile_header = "X-Sendfile"`.

### Nginx

Nginx uses an equivalent that's called `X-Accel-Redirect`, further instructions can be found [in their wiki](http://wiki.nginx.org/XSendfile).

Rails' will need to be configured to `config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"`.

### Lighttpd

Lighty is more `X-Sendfile`, like [outlined](http://redmine.lighttpd.net/projects/1/wiki/X-LIGHTTPD-send-file) in their wiki.


Contributing
------------

1. Fork
2. Hack
3. `rake test`
4. Send a pull request


Releasing a new version
-----------------------

1. Update the version in `delayed_job_web.gemspec`
2. `git commit delayed_job_web.gemspec` with the following message format:

        Version x.x.x

        Changelog:
        * Some new feature
        * Some new bug fix
3. `rake release`


Author
------

Erick Schmitt - [@ejschmitt][1]


[0]: https://github.com/defunkt/resque
[1]: http://twitter.com/ejschmitt
