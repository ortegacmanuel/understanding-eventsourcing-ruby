require_relative '../../lib/slice'
require_relative 'api'

module RemoveItem
  extend Slice

  on_boot do |event_store:, app:, container:, **_|
    RemoveItem::API.set :event_store, event_store
    app.use RemoveItem::API
  end
end 