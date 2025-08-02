require_relative '../../lib/slice'
require_relative 'clear_cart'

module ClearCartSlice
  extend Slice

  on_boot do |event_store:, app:, **_|
    ClearCart.set :event_store, event_store
    app.use ClearCart
  end
end 