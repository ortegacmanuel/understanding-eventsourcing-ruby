require 'rack'
require 'bundler/setup'

require 'kroniko'
require 'sinatra'
require "sinatra/reloader" if development?


require_relative 'slices/add_item'

class App < Sinatra::Base
  event_store = Kroniko::EventStore.new

  AddItem.set :event_store, event_store
  use AddItem
end
