delayed_job_web
===============

A [resque][0] inspired (read: stolen) interface for delayed_job.
This gem is written to work with rails 3 applications using
activerecord.

Some features:

* Easily view jobs enqueued, working, pending, and failed.
* Queue any single job. or all pending jobs, to run immediately.
* Remove a failed job, or easily remove all failed jobs.
* Watch delayed_job operation with live ajax polling.

Quick Start For Rails 3 Applications
------------------------------------

Add the dependency to your Gemfile

```ruby
gem "delayed_job_web"
```

Install it...

```ruby
bundle
```

Add a route to your application for accessing the interface

```ruby
match "/delayed_job" => DelayedJobWeb, :anchor => false
```

You probably want to password protect the interface, an easy way is to add something like this your config.ru file

```ruby
if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == 'username' && password == 'password'
  end
end
```

The Interface - Yea, a ripoff of resque-web
------------------------------------

![Screen shot](http://dl.dropbox.com/u/1506097/Screenshots/delayed_job_web_1.png)

![Screen shot](http://dl.dropbox.com/u/1506097/Screenshots/delayed_job_web_2.png)


Author
------

Erick Schmitt - [@ejschmitt][1]


[0]: https://github.com/defunkt/resque
[1]: http://twitter.com/ejschmitt
