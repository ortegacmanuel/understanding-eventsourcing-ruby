require_relative '../../lib/slice'
require_relative 'change_inventory'

module ChangeInventorySlice
  extend Slice

  on_boot do |event_store:, app:, **_|
    ChangeInventory.set :event_store, event_store
    app.use ChangeInventory
  end
end 