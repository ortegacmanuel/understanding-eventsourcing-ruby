require_relative '../../lib/slice'
require_relative 'remove_item'

module RemoveItemSlice
  extend Slice

  on_boot do |event_store:, app:, **_|
    RemoveItem.set :event_store, event_store
    app.use RemoveItem
  end
end 