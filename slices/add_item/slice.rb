require_relative '../../lib/slice'
require_relative 'add_item'

module AddItemSlice
  extend Slice

  on_boot do |event_store:, app:, container:, **_|
    AddItem.set :event_store, event_store
    app.use AddItem
  end
end 