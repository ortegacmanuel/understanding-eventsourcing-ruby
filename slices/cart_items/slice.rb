require_relative '../../lib/slice'
require_relative 'cart_items'

module CartItemsSlice
  extend Slice

  on_boot do |event_store:, app:, container:, **_|
    CartItems.set :event_store, event_store
    app.use CartItems
  end
end 