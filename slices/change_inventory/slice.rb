require_relative '../../lib/slice'
require_relative 'change_inventory'

module ChangeInventory
  extend Slice

  on_boot do |event_store:, app:, **_|
    ChangeInventory::API.set :event_store, event_store
    app.use ChangeInventory::API
  end
end 