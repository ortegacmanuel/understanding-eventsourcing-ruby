require 'rack'
require 'bundler/setup'

require 'eventstore_ruby'
require 'sinatra'
require_relative 'lib/registry'
require_relative 'lib/container'
require "sinatra/reloader" if development?
require_relative 'slices'

class WebApp < Sinatra::Base
  configure do
    set :event_store, App::Registry.event_store
  end
end

# Start every slice with shared dependencies
Slices.boot_all(
  event_store: App::Registry.event_store,
  app: WebApp,
  conn_str: ENV.fetch('DATABASE_URL')
)
