require_relative '../../lib/slice'
require_relative 'projector'
require_relative 'listener'
require_relative 'api'

module Inventories
  extend Slice

  on_boot do |event_store:, app:, conn_str:, container:, **_|
    Projector.create_table(conn_str)
    Listener.start(event_store, conn_str)

    # Example: container.register(:inventories_dataset, ->(cs = conn_str) { Projector.dataset(cs) }) if you later expose it

    API.set :conn_str, conn_str
    app.use API
  end
end 