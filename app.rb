require 'rack'
require 'bundler/setup'

require 'kroniko'
require 'sinatra'
require "sinatra/reloader" if development?

require_relative 'slices/add_item'
require_relative 'slices/cart_items'
require_relative 'slices/remove_item/remove_item'
require_relative 'slices/clear_cart'

class App < Sinatra::Base
  event_store = Kroniko::EventStore.new

  AddItem.set :event_store, event_store
  use AddItem

  CartItems.set :event_store, event_store
  use CartItems

  RemoveItem.set :event_store, event_store
  use RemoveItem

  ClearCart.set :event_store, event_store
  use ClearCart
end
