# frozen_string_literal: true

require 'action_controller/railtie'
require 'logger'
require 'delayed_job_web'

class RailsApp < Rails::Application
  config.logger = Rails.logger = Logger.new(nil)
  config.secret_key_base = 'foo'
  config.session_store :cookie_store, key: '_anything'

  routes.draw do
    match '/delayed_job' => DelayedJobWeb, :anchor => false, via: %i[get post]
  end
end
