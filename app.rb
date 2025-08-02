require 'rack'
require 'bundler/setup'

require 'eventstore_ruby'
require 'sinatra'
require_relative 'lib/container'
require "sinatra/reloader" if development?

require_relative 'slices/add_item/add_item'
require_relative 'slices/cart_items/cart_items'
require_relative 'slices/remove_item/remove_item'
require_relative 'slices/clear_cart/clear_cart'
require_relative 'slices/change_inventory/change_inventory'

require_relative 'slices/inventories/listener'
require_relative 'slices/inventories/projector'
require_relative 'slices/inventories/api'

Inventories::Projector.create_table(ENV.fetch('DATABASE_URL'))
@stop_listener = Inventories::Listener.start(Application::Container.event_store, ENV.fetch('DATABASE_URL'))

class WebApp < Sinatra::Base
  configure do
    set :event_store, Application::Container.event_store
  end

  AddItem.set  :event_store, settings.event_store
  use AddItem

  CartItems.set :event_store, settings.event_store
  use CartItems

  RemoveItem.set :event_store, settings.event_store
  use RemoveItem

  ClearCart.set :event_store, settings.event_store
  use ClearCart

  ChangeInventory.set :event_store, settings.event_store
  use ChangeInventory

  Inventories::API.set :conn_str, ENV.fetch('DATABASE_URL')
  use Inventories::API
end
