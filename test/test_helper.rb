# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'bundler'
Bundler.setup(:default, :development)
require 'minitest/autorun'

ENV['RACK_ENV'] = 'test'
