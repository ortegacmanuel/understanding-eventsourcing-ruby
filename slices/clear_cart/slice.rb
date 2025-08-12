require_relative '../../lib/slice'
require_relative 'clear_cart'

module ClearCart
  extend Slice

  on_boot do |event_store:, app:, container:, **_|
    ClearCart::API.set :event_store, event_store
    app.use ClearCart::API
  end
end 